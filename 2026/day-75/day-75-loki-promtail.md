# Day 75 — Log Management with Loki and Promtail

## Overview

This project adds log aggregation to the existing Prometheus and Grafana observability stack. Loki stores logs, Fluent Bit forwards Docker logs, and Grafana provides log queries and a combined metrics-and-logs dashboard.

> **Environment note:** This project runs in Ubuntu under WSL with Docker Desktop. Docker's container log files are not accessible through the expected `/var/lib/docker/containers/` bind mount in this environment. Promtail's file-based collection was therefore not used for the verified working pipeline. Fluent Bit with Docker's `fluentd` logging driver successfully forwards the application logs to Loki.

## Architecture

```text
notes-app container
       |
       | Docker fluentd logging driver
       v
Fluent Bit (forward input :24224)
       |
       | Loki HTTP push API
       v
Loki (:3100)
       |
       | LogQL queries
       v
Grafana Explore and Dashboard

Prometheus + Node Exporter + cAdvisor
       |
       v
Grafana metrics panel
```

## Components

| Component | Port | Purpose |
|---|---:|---|
| Prometheus | 9090 | Metrics storage and querying |
| Node Exporter | 9100 | Host metrics |
| cAdvisor | 8080 | Container metrics |
| Grafana | 3000 | Dashboards and log exploration |
| Loki | 3100 | Log storage and querying |
| Promtail | 9080 | Configured, but file-based log collection was not working in this Docker Desktop setup |
| Fluent Bit | 24224 | Receives Docker log events and forwards them to Loki |
| Notes app | 8000 | Application generating HTTP request logs |

## Loki Configuration

File: `loki/loki-config.yml`

```yaml
auth_enabled: false

server:
  http_listen_port: 3100

common:
  ring:
    instance_addr: 127.0.0.1
    kvstore:
      store: inmemory
  replication_factor: 1
  path_prefix: /loki

schema_config:
  configs:
    - from: 2020-10-24
      store: tsdb
      object_store: filesystem
      schema: v13
      index:
        prefix: index_
        period: 24h

storage_config:
  filesystem:
    directory: /loki/chunks
```

- `auth_enabled: false`: suitable for this local learning environment; not a production security configuration.
- Port `3100` serves Loki's HTTP API.
- TSDB stores the index, while the filesystem stores log chunks.
- `replication_factor: 1` is suitable for a single-instance lab.

Verify Loki readiness:

```bash
curl -s http://localhost:3100/ready
```

Expected output: `ready`.

## Fluent Bit Configuration

File: `fluent-bit/fluent-bit.conf`

The working configuration uses the Fluent Bit `forward` input on port `24224` and the Loki output plugin.

```ini
[SERVICE]
    Flush        1
    Log_Level    info
    Daemon       off

[INPUT]
    Name    forward
    Listen  0.0.0.0
    Port    24224

[OUTPUT]
    Name        loki
    Match       *
    Host        loki
    Port        3100
    Uri         /loki/api/v1/push
    Labels      job=docker,source=day-75
    Line_Format json
```

The Docker Compose service mounts this file into the Fluent Bit container. Fluent Bit receives log events through the Forward protocol and pushes them to Loki.

The `notes-app` Compose service uses the Docker `fluentd` logging driver with the following settings:

```yaml
logging:
  driver: fluentd
  options:
    fluentd-address: "localhost:24224"
    fluentd-async: "true"
    tag: "docker.notes-app"
```

The asynchronous option allows the container to start without waiting for the logging receiver to become available. Ensure Fluent Bit is running when testing log delivery.

## Promtail Configuration

File: `promtail/promtail-config.yml`

Promtail was configured to read Docker JSON log files from `/var/lib/docker/containers/*/*-json.log` and push them to Loki. In this WSL and Docker Desktop environment, the expected files were not accessible through the bind mount, so Promtail did not discover readable targets. The verified application logging path uses Fluent Bit instead.

## Grafana Data Sources

Loki was added manually in Grafana:

- Data source: Loki
- URL: `http://loki:3100`
- Result: Save & test succeeded

The service name `loki` is used because Grafana connects to Loki over the Docker Compose network.

## LogQL Queries Tested

### 1. Select Docker logs

```logql
{job="docker"}
```

Returns log streams labelled with `job="docker"`.

### 2. Search for application log lines

```logql
{job="docker"} |= "notes-app"
```

Filters log lines containing the text `notes-app`, where present in the log content.

### 3. Search for errors

```logql
{job="docker"} |= "error"
```

Searches for lowercase `error`. No matching lines were returned in the tested time range.

### 4. Exclude error lines

```logql
{job="docker"} != "error"
```

Returns lines that do not contain lowercase `error`.

### 5. Count logs over a five-minute range

```logql
sum(count_over_time({job="docker"}[5m]))
```

Calculates the total number of log entries in the selected five-minute range as a time series.

## Validation

Generate application requests:

```bash
for i in $(seq 1 5); do
  curl -s http://localhost:8000/ > /dev/null
done
```

Check Loki readiness:

```bash
curl -s http://localhost:3100/ready
```

Query recent Docker logs directly from Loki:

```bash
curl -G -s "http://localhost:3100/loki/api/v1/query_range" \
  --data-urlencode 'query={job="docker"}' \
  --data-urlencode "start=$(date -d '15 minutes ago' +%s)000000000" \
  --data-urlencode "end=$(date +%s)000000000" \
  --data-urlencode "limit=10"
```

The query returned `notes-app` HTTP request messages, including `GET / HTTP/1.1` responses with status `200`.

## Grafana Dashboard

Dashboard: **Day 75 - Metrics and Logs**

Panels:

1. **Prometheus Scrape Target Status** — uses the Prometheus query `up`.
2. **Docker Container Logs** — uses the Loki query `{job="docker"}` with Logs visualization.

The dashboard shows metrics and logs together, making it easier to compare service health with application activity.

## Screenshots

Screenshots are stored in `screenshots/`.

1. `screenshots/01-loki-datasource-connected.png` — Loki data source configuration.
2. `screenshots/02-grafana-explore-docker-logs.png` — Docker logs in Grafana Explore.
3. `screenshots/03-notes-app-logs.png` — application log filtering.
4. `screenshots/04-logql-negative-filter.png` — negative LogQL filter.
5. `screenshots/05-logql-count-over-time.png` — log count query.
6. `screenshots/06-day75-metrics-and-logs-dashboard.png` — combined dashboard.

## Loki vs. ELK

| Area | Loki | ELK stack |
|---|---|---|
| Indexing | Primarily indexes labels | Elasticsearch indexes document fields and supports full-text search |
| Resource needs | Often lighter for label-oriented log workloads | Can require more storage and compute, depending on indexing and retention |
| Querying | LogQL | Elasticsearch Query DSL / Kibana |
| Good fit | Cost-conscious observability integrated with Grafana | Rich full-text search, analytics, and complex document queries |

Loki is a good fit when logs are queried by stable labels and integrated with Prometheus metrics. ELK is useful when powerful full-text search and document-oriented analysis are important.

## Lessons Learned

- Docker Desktop's internal log storage is not necessarily accessible through a Linux host bind mount.
- Docker's `fluentd` logging driver can forward application logs to Fluent Bit.
- Loki uses labels to identify streams, while LogQL filters the content of log lines.
- Grafana provides a single interface for exploring metrics and logs.

## Status

- [x] Loki running and ready
- [x] Fluent Bit forwarding `notes-app` logs to Loki
- [x] Loki data source connected in Grafana
- [x] LogQL filters and count query tested
- [x] Metrics-and-logs dashboard created
- [x] Six screenshots saved
- [ ] Commit and push the Day 75 files
