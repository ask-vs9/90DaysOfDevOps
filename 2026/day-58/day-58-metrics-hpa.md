# Day 58 – Metrics Server and Horizontal Pod Autoscaler (HPA)

> **90DaysOfDevOps – Day 58**
>
> Practical work with Kubernetes Metrics Server, `kubectl top`, and Horizontal Pod Autoscaler (HPA).

---

## 📌 Objective

The goal of Day 58 was to use Kubernetes resource metrics for automatic horizontal scaling.

I completed the following:

- Enabled and verified Metrics Server.
- Used `kubectl top` to inspect CPU and memory usage.
- Created a PHP-Apache deployment with a CPU request.
- Created an HPA with a 50% CPU utilization target.
- Generated HTTP traffic against the application.
- Observed HPA automatically increase the number of replicas.
- Created a declarative HPA using `autoscaling/v2`.
- Configured scale-up and scale-down behavior.
- Captured screenshots only at important verification points.

---

## 🖥️ Environment

| Item | Details |
|---|---|
| Kubernetes | Minikube |
| Working directory | `2026/day-58` |
| Application | PHP-Apache HPA example |
| CPU request | `200m` |
| HPA CPU target | `50%` |
| Minimum replicas | `1` |
| Maximum replicas | `10` |
| HPA API version | `autoscaling/v2` |

---

# Task 1 – Install and Verify Metrics Server

## 1. Check Metrics Server

```bash
kubectl get pods -n kube-system | grep metrics-server
```

Because this lab uses Minikube, Metrics Server can be enabled with:

```bash
minikube addons enable metrics-server
```

## 2. Verify resource metrics

```bash
kubectl top nodes
```

```bash
kubectl top pods -A
```

Metrics Server makes current CPU and memory usage available to Kubernetes.

### Screenshots

![Minikube cluster information](day58_task1_cluster_info.png)

![Metrics Server verification](day58_task1_metrics-server.png)

---

# Task 2 – Explore `kubectl top`

The `kubectl top` command displays the **current resource usage** of nodes and pods.

## Commands

```bash
kubectl top nodes
```

```bash
kubectl top pods -A
```

```bash
kubectl top pods -A --sort-by=cpu
```

## Important distinction

`kubectl top` shows **actual resource usage**.

It does not show the configured resource requests or limits.

For example:

```text
kubectl top
    ↓
Actual CPU / Memory usage

Pod specification
    ↓
CPU / Memory requests and limits
```

Metrics Server provides the usage data used by HPA.

### Verification

The exact highest-CPU pod from the `--sort-by=cpu` output was not captured in the saved Day 58 screenshots, so no pod name/value is invented here.

---

# Task 3 – Create the PHP-Apache Deployment

The PHP-Apache application was configured with a CPU request.

## CPU request

```yaml
resources:
  requests:
    cpu: 200m
```

The CPU request is important because the CPU-based HPA calculates utilization as a percentage of the requested CPU.

## Apply the deployment

```bash
kubectl apply -f php-apache.yaml
```

## Expose the deployment

```bash
kubectl expose deployment php-apache --port=80
```

## Verify

```bash
kubectl get deployment php-apache
```

```bash
kubectl get pods
```

```bash
kubectl top pods
```

### Result

The `php-apache` deployment was created successfully and became available for HPA testing.

The CPU request used for the application was:

```text
200m
```

No separate Task 3 screenshot was saved because the later HPA screenshots provide the important scaling verification.

---

# Task 4 – Create the HPA Imperatively

The initial HPA was created using the imperative command:

```bash
kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10
```

## Verify the HPA

```bash
kubectl get hpa
```

```bash
kubectl describe hpa php-apache
```

The HPA configuration was:

```text
Target CPU utilization: 50%
Minimum replicas:       1
Maximum replicas:       10
```

### Screenshot

![HPA status](day58_task4_hpa.png)

---

# Task 5 – Generate Load and Observe Autoscaling

A BusyBox pod was used to continuously send HTTP requests to the PHP-Apache service.

## 1. Create the load generator

```bash
kubectl run load-generator --image=busybox:1.36 --restart=Never -- /bin/sh -c "while true; do wget -q -O- http://php-apache; done"
```

## 2. Verify the load generator

```bash
kubectl get pod load-generator
```

During the lab, the load-generator initially encountered a container startup problem in the Minikube/Windows environment. After recreating the pod, the load test successfully ran.

## 3. Observe HPA

```bash
kubectl get hpa php-apache --watch
```

## Observed result

The HPA reacted to the increased CPU utilization.

One observed state was:

```text
CPU: 23% / 50%
Replicas: 3
```

Later, under continued load:

```text
CPU: 53% / 50%
Replicas: 9
```

Therefore, the deployment scaled from its initial single replica to **9 replicas** during the load test.

This demonstrated horizontal scaling based on CPU utilization.

### Screenshot

![HPA scaling under load](day58_task5-hpa-scaling.png)

---

# Task 6 – Create an HPA Declaratively with `autoscaling/v2`

The imperative HPA was removed:

```bash
kubectl delete hpa php-apache
```

A YAML-based HPA was then configured using:

```yaml
apiVersion: autoscaling/v2
```

## HPA configuration

```text
Target CPU utilization: 50%
Minimum replicas:       1
Maximum replicas:       10
```

## HPA behavior

The HPA YAML includes a `behavior` section.

### Scale-up

The configuration uses:

```text
stabilizationWindowSeconds: 0
```

This allows scale-up without a stabilization delay.

### Scale-down

The configuration uses:

```text
stabilizationWindowSeconds: 300
```

This provides a 5-minute stabilization window for scale-down decisions.

## Apply the declarative HPA

```bash
kubectl apply -f php-apache-hpa.yaml
```

## Verify

```bash
kubectl get hpa
```

```bash
kubectl describe hpa php-apache
```

The captured verification showed:

```text
Current CPU: 53%
Target CPU: 50%

Current replicas: 9
Desired replicas: 9

Scale-up stabilization window: 0 seconds
Scale-down stabilization window: 300 seconds
```

The HPA conditions also showed that the metric was successfully available and the HPA was able to calculate a replica count.

### Screenshot

![HPA YAML behavior](day58_task6-hpa-yaml-behavior.png)

---

# Task 7 – Clean Up

After completing the HPA testing, the temporary application resources can be removed.

## Delete the HPA

```bash
kubectl delete hpa php-apache
```

## Delete the Service

```bash
kubectl delete service php-apache
```

## Delete the Deployment

```bash
kubectl delete deployment php-apache
```

## Delete the load generator

```bash
kubectl delete pod load-generator
```

### Important

Metrics Server should remain installed because it is a cluster-level component used by future HPA exercises.

---

# 🧠 Key Concepts Learned

## 1. Metrics Server

Metrics Server provides current resource usage metrics for Kubernetes nodes and pods.

HPA uses these metrics when making resource-based scaling decisions.

---

## 2. Horizontal Pod Autoscaler

HPA automatically changes the number of replicas of a workload according to configured metrics and scaling rules.

In this exercise, CPU utilization was used as the scaling metric.

---

## 3. CPU Requests and HPA

CPU requests are important for CPU-utilization-based HPA.

Example:

```text
CPU request = 200m
Current CPU usage = 100m
```

The utilization is:

```text
100m / 200m × 100
= 50%
```

Therefore, 100m of CPU usage represents 50% utilization when the request is 200m.

---

## 4. Desired Replica Calculation

A simplified representation of the HPA calculation is:

```text
desiredReplicas =
ceil(currentReplicas × currentUsage / targetUsage)
```

Example:

```text
Current replicas = 3
Current utilization = 100%
Target utilization = 50%

desiredReplicas =
ceil(3 × 100 / 50)

= 6
```

This illustrates why higher utilization can cause HPA to increase the replica count.

---

# `autoscaling/v1` vs `autoscaling/v2`

| Feature | `autoscaling/v1` | `autoscaling/v2` |
|---|---|---|
| CPU resource metric | Yes | Yes |
| Memory resource metric | Limited | Yes |
| Multiple metrics | Limited | Yes |
| Custom/external metrics | Limited | Yes |
| Scaling behavior configuration | Limited | Yes |
| Fine-grained scaling controls | Limited | Yes |

For this exercise, `autoscaling/v2` was used because it supports the more detailed `behavior` configuration.

---

# 📸 Screenshots Collected

Only the important verification screenshots were captured.

| Task | Screenshot |
|---|---|
| Task 1 | `day58_task1_cluster_info.png` |
| Task 1 | `day58_task1_metrics-server.png` |
| Task 4 | `day58_task4_hpa.png` |
| Task 5 | `day58_task5-hpa-scaling.png` |
| Task 6 | `day58_task6-hpa-yaml-behavior.png` |

This keeps the documentation useful without creating unnecessary screenshots for every command.

---

# 📁 Day 58 Files

The Day 58 directory contains:

```text
README.md
php-apache.yaml
php-apache-hpa.yaml
day58_task1_cluster_info.png
day58_task1_metrics-server.png
day58_task4_hpa.png
day58_task5-hpa-scaling.png
day58_task6-hpa-yaml-behavior.png
day-58-metrics-hpa.md
```

---

# 🔄 Day 58 Workflow

```text
                 Metrics Server
                       │
                       ▼
                  kubectl top
                       │
                       ▼
              Resource usage data
                       │
                       ▼
              PHP-Apache Deployment
                       │
                 CPU request 200m
                       │
                       ▼
                 HPA target 50%
                       │
                       ▼
                 Load generator
                       │
                       ▼
                 CPU utilization ↑
                       │
                       ▼
                HPA scales replicas
                       │
                       ▼
             1 replica → 9 replicas
                       │
                       ▼
             Load removed / reduced
                       │
                       ▼
              Scale-down stabilization
```

---

# ✅ Final Result

Day 58 demonstrated how Kubernetes can use real-time resource metrics to automatically adjust application capacity.

The practical result was successful HPA scaling of the PHP-Apache workload under generated traffic, with the HPA observed reaching **9 replicas** while the configured maximum was **10 replicas**.

The exercise also demonstrated the difference between:

- Actual resource usage (`kubectl top`)
- Resource requests/limits
- HPA target utilization
- Imperative HPA configuration
- Declarative `autoscaling/v2` configuration
- Scale-up and scale-down behavior

---

## Submission

Place this file in:

```text
2026/day-58/day-58-metrics-hpa.md
```

Then commit and push:

```bash
git add day-58-metrics-hpa.md
git commit -m "Day 58: Metrics Server and HPA"
git push origin master
```
