# Day 55 – Persistent Volumes (PV) and Persistent Volume Claims (PVC)

## Overview

Containers are ephemeral, so data stored inside a Pod can disappear when the Pod is deleted. Kubernetes Persistent Volumes (PV) and Persistent Volume Claims (PVC) provide persistent storage that can survive Pod deletion and recreation.

---

# Task 1: See the Problem — Data Lost on Pod Deletion

An `emptyDir` volume was used to demonstrate ephemeral storage.

The Pod wrote a timestamped message to `/data/message.txt`. The file was verified with `kubectl exec`.

After deleting and recreating the Pod, the previous file was gone and a new timestamp was created. This demonstrated that `emptyDir` data is tied to the Pod lifecycle.

### Evidence

![Ephemeral data before delete](day55-ephemeral-data-before-delete.png)

![Ephemeral data lost](day55-ephemeral-data-lost.png)

---

# Task 2: Create a PersistentVolume (Static Provisioning)

A PersistentVolume was created manually with:

- Capacity: `1Gi`
- Access mode: `ReadWriteOnce`
- Reclaim policy: `Retain`
- Storage type: `hostPath`
- Host path: `/tmp/k8s-pv-data`

The PV was verified with:

```bash
kubectl get pv
```

The PV initially showed `Available`.

### Evidence

![PV Available](day55-pv-available.png)

![Manual PV Retained](day55-manual-pv-retained.png)

> `hostPath` was used for this learning exercise and is not generally suitable as a production multi-node storage solution.

---

# Task 3: Create a PersistentVolumeClaim

A PVC was created requesting:

- Storage: `500Mi`
- Access mode: `ReadWriteOnce`

The PVC and PV became `Bound`.

### Evidence

![PVC Bound](day55-pvc-bound.png)

---

# Task 4: Use the PVC in a Pod — Data That Survives

The PVC was mounted into a Pod at `/data`.

Data was written to:

```text
/data/message.txt
```

The Pod was then deleted and recreated. The data remained available because the storage was backed by the PVC/PV.

### Evidence

![PVC Pod Running](day-55-pvc-pod-running.png)

![PVC Data Verified](day-55-pvc-data-verified.png)

![PVC Pod Deleted](day55-pvc-pod-deleted.png)

![PVC Pod Recreated](day55-pvc-pod-recreated.png)

![PVC Pod Running After Recreate](day55-pvc-pod-running-after-recreate.png)

![PVC Data Persisted](day55-pvc-data-persisted.png)

![PVC Data Persisted After Recreate](day55-pvc-data-persisted-after-recreate.png)

---

# Task 5: StorageClasses and Dynamic Provisioning

The cluster StorageClass was inspected using:

```bash
kubectl get storageclass
kubectl describe storageclass standard
```

The default StorageClass in this Minikube cluster was:

```text
Name: standard
Provisioner: k8s.io/minikube-hostpath
ReclaimPolicy: Delete
VolumeBindingMode: Immediate
IsDefaultClass: Yes
```

### Evidence

![StorageClass Verification](day55-storageclass-verified.png)

---

# Task 6: Dynamic Provisioning

A PVC using:

```yaml
storageClassName: standard
```

was created.

Kubernetes automatically provisioned a PV for the PVC.

### Evidence

![Dynamic PVC Bound](day-55-dynamic-pvc-bound.png)

![Dynamic PV Created](day-55-dynamic-pv-created.png)

![Dynamic PVC Pod Running](day-55-dynamic-pvc-pod-running.png)

![Dynamic PVC Data Verified](day-55-dynamic-pvc-data-verified.png)

The dynamically provisioned PV used the `standard` StorageClass and was successfully consumed by the Pod.

---

# Task 7: Clean Up

The dynamically provisioned Pod and PVC were deleted and the PV state was checked.

The dynamic StorageClass used:

```text
ReclaimPolicy: Delete
```

so the dynamically provisioned PV was automatically removed when its PVC was deleted.

The manually created PV used:

```text
persistentVolumeReclaimPolicy: Retain
```

and was retained until it was manually deleted.

### Evidence

![Dynamic PV Bound](day55-task7-dynamic-pv-bound.png)

![Dynamic PV Automatically Deleted](day55-dynamic-pv-auto-deleted.png)

![Manual PV Retained](day55-manual-pv-retained.png)

![Cleanup Complete](day55-cleanup-complete.png)

---

# PV vs PVC

## PersistentVolume (PV)

A PV is a cluster-level storage resource. It defines storage capacity, access modes, reclaim policy, and the underlying storage mechanism.

## PersistentVolumeClaim (PVC)

A PVC is a request for storage made by a user or application. It requests capacity, access mode, and optionally a StorageClass.

Relationship:

```text
Application / Pod
       |
       v
      PVC
       |
       v
      PV
       |
       v
Underlying Storage
```

With dynamic provisioning:

```text
Application / Pod
       |
       v
      PVC
       |
       v
 StorageClass
       |
       v
 Automatically created PV
       |
       v
Underlying Storage
```

---

# Static vs Dynamic Provisioning

| Feature | Static Provisioning | Dynamic Provisioning |
|---|---|---|
| PV creation | Manually created | Automatically created |
| PVC | Created by user | Created by user |
| StorageClass | Not necessarily required | Used for provisioning |
| Example | Manual `hostPath` PV | `standard` StorageClass |
| Management | Administrator manages PVs | Kubernetes provisions PVs automatically |

---

# Access Modes

| Access Mode | Meaning |
|---|---|
| `ReadWriteOnce (RWO)` | Read-write by a single node |
| `ReadOnlyMany (ROX)` | Read-only by many nodes |
| `ReadWriteMany (RWX)` | Read-write by many nodes |

---

# Reclaim Policies

| Policy | Behavior |
|---|---|
| `Retain` | Keeps the PV after the PVC is deleted |
| `Delete` | Deletes the dynamically provisioned PV when the PVC is deleted |

---

# Key Learnings

- `emptyDir` data does not survive Pod deletion.
- PersistentVolumes provide cluster-level persistent storage.
- PersistentVolumeClaims request persistent storage.
- PVCs can bind to matching PVs.
- PVs are cluster-scoped; PVCs are namespace-scoped.
- StorageClasses enable dynamic provisioning.
- The Minikube `standard` StorageClass used the `k8s.io/minikube-hostpath` provisioner.
- `Retain` keeps a PV after PVC deletion.
- `Delete` removes a dynamically provisioned PV when its PVC is deleted.

---

# Commands Used

```bash
kubectl get pods
kubectl get pv
kubectl get pvc
kubectl get storageclass
kubectl describe storageclass standard
kubectl exec <pod-name> -- cat /data/message.txt
kubectl delete pod <pod-name>
kubectl delete pvc <pvc-name>
kubectl delete pv <pv-name>
```

For Git Bash on Windows, the following was used when necessary to prevent MSYS path conversion:

```bash
MSYS_NO_PATHCONV=1 kubectl exec dynamic-pvc-pod -- cat /data/message.txt
```

---

# Day 55 Completion

- [x] Demonstrated ephemeral data loss with `emptyDir`
- [x] Created a static PersistentVolume
- [x] Created and bound a PersistentVolumeClaim
- [x] Verified persistent data across Pod deletion and recreation
- [x] Inspected the default StorageClass
- [x] Tested dynamic provisioning
- [x] Verified dynamically provisioned storage
- [x] Completed cleanup
- [x] Collected evidence screenshots
- [x] Created Day 55 documentation

## Submission

```text
2026/day-55/day-55-persistent-volumes.md
```

Recommended Git commands:

```bash
git add 2026/day-55/
git commit -m "Complete Day 55 Persistent Volumes and PVCs"
git push origin master
```

## Learn in Public

> Learned Kubernetes Persistent Volumes and PVCs today. Proved container data is ephemeral, then fixed it with PVs. Also explored dynamic provisioning with StorageClasses.

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`
