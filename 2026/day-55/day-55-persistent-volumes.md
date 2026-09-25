# Day 55 -- Persistent Volumes (PV) and Persistent Volume Claims (PVC)

## Objective

Containers are ephemeral, so data stored inside a container or Pod can
disappear when the Pod is deleted. Kubernetes Persistent Volumes (PV)
and Persistent Volume Claims (PVC) provide persistent storage so
application data can survive Pod restarts and recreations.

------------------------------------------------------------------------

## 1. Ephemeral Storage -- Data Loss

An `emptyDir` volume was used to demonstrate ephemeral storage.

The Pod wrote a timestamped message to `/data/message.txt`. The file was
verified with `kubectl exec`.

After deleting and recreating the Pod, the previous file was gone and a
new timestamp was created. This demonstrated that `emptyDir` data is
tied to the Pod lifecycle.

### Evidence

-   `day55-ephemeral-data-before-delete.png`
-   `day55-ephemeral-data-lost.png`

------------------------------------------------------------------------

## 2. PersistentVolume (PV) -- Static Provisioning

A PersistentVolume was created manually with:

-   Capacity: `1Gi`
-   Access Mode: `ReadWriteOnce`
-   Reclaim Policy: `Retain`
-   Storage type: `hostPath`
-   Host path: `/tmp/k8s-pv-data`

It was verified with:

``` bash
kubectl get pv
```

The PV initially showed `Available`.

### Access Modes

  Access Mode   Meaning
  ------------- -----------------------------
  RWO           Read-write by a single node
  ROX           Read-only by many nodes
  RWX           Read-write by many nodes

`hostPath` was used for this learning exercise and is not generally
suitable as a production storage solution.

### Evidence

-   `day55-pv-available.png`
-   `day55-manual-pv-retained.png`

------------------------------------------------------------------------

## 3. PersistentVolumeClaim (PVC)

A PVC was created requesting:

-   Storage: `500Mi`
-   Access Mode: `ReadWriteOnce`

It was verified with:

``` bash
kubectl get pvc
kubectl get pv
```

The PVC and PV became `Bound`. The PVC `VOLUME` column showed the PV to
which the claim was bound.

### Evidence

-   `day55-pvc-bound.png`

------------------------------------------------------------------------

## 4. Using the PVC in a Pod

A Pod mounted the PVC at `/data` and wrote data to `/data/message.txt`.

The Pod was deleted and recreated. The file was checked again and the
persistent data remained available.

This demonstrated that the data was stored through persistent storage
rather than being tied only to the Pod.

### Evidence

-   `day55-pvc-pod-running.png`
-   `day55-pvc-data-verified.png`
-   `day55-pvc-pod-deleted.png`
-   `day55-pvc-pod-recreated.png`
-   `day55-pvc-pod-running-after-recreate.png`
-   `day55-pvc-data-persisted.png`
-   `day55-pvc-data-persisted-after-recreate.png`

------------------------------------------------------------------------

## 5. StorageClass and Dynamic Provisioning

The StorageClass was inspected using:

``` bash
kubectl get storageclass
kubectl describe storageclass standard
```

The cluster used:

``` text
Name: standard
Provisioner: k8s.io/minikube-hostpath
ReclaimPolicy: Delete
VolumeBindingMode: Immediate
IsDefaultClass: Yes
```

A StorageClass defines how storage is dynamically provisioned. With
dynamic provisioning, developers create PVCs and Kubernetes uses the
StorageClass to create the required PV automatically.

### Evidence

-   `day55-storage-class-verified.png`

------------------------------------------------------------------------

## 6. Dynamic Provisioning

A PVC using the `standard` StorageClass was created.

Kubernetes automatically created a PV. The dynamically created PV
showed:

``` text
CAPACITY: 500Mi
ACCESS MODES: RWO
RECLAIM POLICY: Delete
STATUS: Bound
STORAGECLASS: standard
```

The PVC was mounted by `dynamic-pvc-pod`.

The Pod was verified with:

``` bash
kubectl get pod dynamic-pvc-pod
```

Data was verified with:

``` bash
MSYS_NO_PATHCONV=1 kubectl exec dynamic-pvc-pod -- cat /data/message.txt
```

The output confirmed the dynamic PVC data was present.

### Evidence

-   `day-55-dynamic-pv-created.png`
-   `day55-task7-dynamic-pv-bound.png`
-   `day-55-dynamic-pvc-pod-running.png`
-   `day-55-dynamic-pvc-data-verified.png`

------------------------------------------------------------------------

## 7. Cleanup and Reclaim Policy

The dynamically provisioned Pod and PVC were deleted and the PV state
was checked.

The dynamic StorageClass used:

``` text
ReclaimPolicy: Delete
```

Therefore, the dynamically provisioned PV was automatically deleted when
its PVC was removed.

Cleanup was verified with:

``` bash
kubectl get pods
kubectl get pvc
kubectl get pv
```

The final cleanup showed no remaining resources for this exercise.

The manually created PV used the `Retain` policy, while the dynamically
provisioned PV used the `Delete` policy.

### Reclaim Policies

  -----------------------------------------------------------------------
  Policy                              Behavior
  ----------------------------------- -----------------------------------
  Retain                              Keeps the PV after the PVC is
                                      deleted; it can enter `Released`
                                      state

  Delete                              Deletes a dynamically provisioned
                                      PV when the PVC is deleted
  -----------------------------------------------------------------------

### Evidence

-   `day55-dynamic-pv-auto-deleted.png`
-   `day55-cleanup-complete.png`

------------------------------------------------------------------------

## 8. PV vs PVC

### PersistentVolume (PV)

A PV is a cluster-level storage resource. It defines storage capacity,
access modes, reclaim policy, and the underlying storage mechanism.

### PersistentVolumeClaim (PVC)

A PVC is a request for storage made by a user or application. It
requests properties such as capacity, access mode, and StorageClass.

### Relationship

``` text
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

``` text
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

------------------------------------------------------------------------

## 9. Static vs Dynamic Provisioning

  -----------------------------------------------------------------------
  Feature                 Static Provisioning     Dynamic Provisioning
  ----------------------- ----------------------- -----------------------
  PV creation             Manually created        Automatically created

  PVC                     Created by user         Created by user

  StorageClass            Not necessarily         Used for provisioning
                          required                

  Example                 Manual `hostPath` PV    `standard` StorageClass

  Management              Administrator manages   Kubernetes provisions
                          PVs                     PVs automatically
  -----------------------------------------------------------------------

------------------------------------------------------------------------

## 10. Key Learnings

-   Pod/container storage can be ephemeral.
-   `emptyDir` data does not survive Pod deletion.
-   A PV provides persistent storage at the cluster level.
-   A PVC is a request for persistent storage.
-   PVCs can bind to matching PVs.
-   PVs are cluster-scoped; PVCs are namespaced.
-   `RWO` allows read-write access from a single node.
-   `ROX` allows read-only access from many nodes.
-   `RWX` allows read-write access from many nodes.
-   `Retain` keeps a PV after its PVC is deleted.
-   `Delete` removes a dynamically provisioned PV when its PVC is
    deleted.
-   StorageClasses enable dynamic provisioning.
-   The Minikube `standard` StorageClass used the
    `k8s.io/minikube-hostpath` provisioner in this exercise.

------------------------------------------------------------------------

## 11. Commands Used

``` bash
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

For Git Bash on Windows, the following was used when necessary to
prevent MSYS path conversion:

``` bash
MSYS_NO_PATHCONV=1 kubectl exec dynamic-pvc-pod -- cat /data/message.txt
```

------------------------------------------------------------------------

## 12. Day 55 Completion

The Day 55 exercise demonstrated:

-   Ephemeral data loss with `emptyDir`
-   Static PV creation
-   PVC creation and PV/PVC binding
-   Persistent data across Pod deletion and recreation
-   StorageClass inspection
-   Dynamic PV provisioning
-   Data access through a dynamically provisioned PVC
-   Reclaim policy behavior
-   Resource cleanup

### Submission

Required documentation file:

``` text
2026/day-55/day-55-persistent-volumes.md
```

Recommended Git commands:

``` bash
git status
git add 2026/day-55/day-55-persistent-volumes.md
git commit -m "Complete Day 55 persistent volumes and PVCs"
git push origin master
```

## Learn in Public

> Learned Kubernetes Persistent Volumes and PVCs today. Proved container
> data is ephemeral, then fixed it with PVs. Also explored dynamic
> provisioning with StorageClasses.

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`
