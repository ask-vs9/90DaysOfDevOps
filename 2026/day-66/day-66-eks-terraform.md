# Day 66 – Provision an EKS Cluster with Terraform

## Objective

Provision an Amazon EKS cluster using Terraform modules, connect to it with `kubectl`, deploy Nginx with three replicas behind an AWS LoadBalancer, verify the application, and destroy the lab infrastructure to avoid ongoing charges.

## Environment

| Setting | Value |
|---|---|
| AWS Region | `ap-south-1` (Mumbai) |
| EKS Cluster | `terraweek-eks` |
| Kubernetes Version | `1.35` |
| Worker Node Instance Type | `t3.medium` |
| Desired Worker Nodes | `2` |
| VPC CIDR | `10.0.0.0/16` |
| Network | Two public and two private subnets across two Availability Zones |
| Nginx Replicas | `3` |

## Project Structure

Keep this Markdown file and the screenshot PNG files in `2026/day-66/`. The image links below are relative to that directory.

```text
2026/day-66/
├── day-66-eks-terraform.md
├── 01-day-66-project-setup.png
├── 02-day-66-vpc-terraform-plan.png
├── 03-day-66-eks-module-validation.png
├── 04-day-66-eks-terraform-plan.png
├── 05-day-66-eks-version-compatibility.png
├── 05-day-66-eks-terraform-apply.png
├── 06-day-66-eks-cluster-nodes-pods.png
├── 07-day-66-nginx-pods-running.png
├── 08-day-66-nginx-loadbalancer-browser.png
├── 09-day-66-terraform-destroy.png
├── k8s/
│   └── nginx-deployment.yaml
└── terraform-eks/
    ├── .gitignore
    ├── .terraform.lock.hcl
    ├── providers.tf
    ├── vpc.tf
    ├── eks.tf
    ├── variables.tf
    └── outputs.tf
```

> `terraform.tfvars`, Terraform state files, and the `.terraform/` working directory should remain excluded from Git.

## 1. Terraform Project Setup

Created the `terraform-eks/` directory and the Terraform configuration files:

- `providers.tf` – Terraform and provider requirements and the AWS provider.
- `vpc.tf` – VPC module configuration.
- `eks.tf` – EKS module and managed node group.
- `variables.tf` – Input variables.
- `outputs.tf` – Cluster name, endpoint, and region outputs.
- `.terraform.lock.hcl` – Provider dependency lock file.

**Screenshot – Project setup**

![Day 66 project setup](./01-day-66-project-setup.png)

## 2. VPC Configuration

Used the Terraform AWS VPC module to create:

- One VPC with CIDR `10.0.0.0/16`.
- Two public subnets and two private subnets across two Availability Zones.
- An Internet Gateway and route tables.
- One NAT Gateway for outbound access from private subnets.
- DNS support and DNS hostnames.
- Kubernetes subnet tags for external and internal load balancers.

**Screenshot – VPC Terraform plan**

![VPC Terraform plan](./02-day-66-vpc-terraform-plan.png)

## 3. EKS Module and Validation

Configured `terraform-aws-modules/eks/aws` with a managed node group using `t3.medium` instances and the `AL2023_x86_64_STANDARD` AMI type. Cluster creator administrator permissions were enabled to allow the creating AWS identity to administer the cluster with `kubectl`.

Ran the following commands:

```bash
terraform fmt
terraform init
terraform validate
terraform plan
```

**Screenshot – EKS module validation**

![EKS module validation](./03-day-66-eks-module-validation.png)

**Screenshot – EKS Terraform plan**

![EKS Terraform plan](./04-day-66-eks-terraform-plan.png)

**Screenshot – EKS version compatibility check**

![EKS version compatibility check](./05-day-66-eks-version-compatibility.png)

## 4. Provision the Infrastructure

Applied the reviewed Terraform configuration:

```bash
terraform apply
```

After reviewing the plan, confirmed the operation by entering `yes`. Terraform reported:

```text
Apply complete! Resources: 57 added, 0 changed, 0 destroyed.
```

**Screenshot – Terraform apply completed**

![Terraform apply completed](./05-day-66-eks-terraform-apply.png)

## 5. Connect `kubectl` and Verify the Cluster

Updated the local kubeconfig:

```bash
aws eks update-kubeconfig --region ap-south-1 --name terraweek-eks
```

Verified the worker nodes and system pods:

```bash
kubectl get nodes
kubectl get pods -A
```

Both worker nodes reported `Ready`. The listed AWS networking, CoreDNS, and kube-proxy pods were running at the time of verification.

**Screenshot – EKS nodes and system pods**

![EKS cluster nodes and system pods](./06-day-66-eks-cluster-nodes-pods.png)

## 6. Deploy and Test Nginx

Created `k8s/nginx-deployment.yaml` with a Deployment containing three Nginx replicas and a `LoadBalancer` Service exposing port 80.

Applied the manifest and checked the pods:

```bash
kubectl apply -f ../k8s/nginx-deployment.yaml
kubectl get pods
```

All three Nginx pods reached `Running` and `1/1 Ready`.

**Screenshot – Nginx pods running**

![Nginx pods running](./07-day-66-nginx-pods-running.png)

Checked the service and waited for AWS to provision the external load balancer:

```bash
kubectl get svc nginx-service
```

Opened the external hostname in a browser and confirmed that the default **“Welcome to nginx!”** page loaded successfully.

**Screenshot – Nginx through the AWS LoadBalancer**

![Nginx welcome page through the AWS LoadBalancer](./08-day-66-nginx-loadbalancer-browser.png)

## 7. Clean Up the Resources

Deleted the Kubernetes resources before destroying the infrastructure:

```bash
kubectl delete -f ../k8s/nginx-deployment.yaml
kubectl get svc nginx-service
kubectl get svc
```

Confirmed that `nginx-service` was no longer found and that only the default `kubernetes` service remained. Then destroyed the Terraform-managed infrastructure:

```bash
terraform destroy
```

Reviewed the deletion plan and confirmed it by entering `yes`. Terraform reported:

```text
Destroy complete! Resources: 57 destroyed.
```

**Screenshot – Terraform destroy completed**

![Terraform destroy completed](./09-day-66-terraform-destroy.png)

## Results

- Provisioned an EKS cluster and managed node group using Terraform modules.
- Connected to the cluster using `kubectl`.
- Verified worker nodes and Kubernetes system pods.
- Deployed three Nginx replicas and exposed them through an AWS LoadBalancer.
- Confirmed the Nginx welcome page was reachable through the external hostname.
- Deleted the Kubernetes resources and destroyed all 57 Terraform-managed resources.

## Cost and Cleanup Note

EKS, EC2 worker nodes, NAT Gateways, public IPv4 addresses, and load balancers can incur charges while provisioned. Terraform reported that all 57 managed resources were destroyed. As a final safety check, verify in the AWS Console that no lab-related resources remain.

## Screenshot Index

| Screenshot | Evidence |
|---|---|
| [01 – Project setup](./01-day-66-project-setup.png) | Terraform directory and configuration files |
| [02 – VPC plan](./02-day-66-vpc-terraform-plan.png) | VPC module plan |
| [03 – EKS module validation](./03-day-66-eks-module-validation.png) | Terraform validation |
| [04 – EKS plan](./04-day-66-eks-terraform-plan.png) | EKS infrastructure plan |
| [05 – Version compatibility](./05-day-66-eks-version-compatibility.png) | EKS version compatibility check |
| [05 – Terraform apply](./05-day-66-eks-terraform-apply.png) | Infrastructure creation completed |
| [06 – Nodes and system pods](./06-day-66-eks-cluster-nodes-pods.png) | Worker nodes and system pods |
| [07 – Nginx pods](./07-day-66-nginx-pods-running.png) | Three Nginx replicas running |
| [08 – Nginx browser test](./08-day-66-nginx-loadbalancer-browser.png) | Nginx reachable through LoadBalancer |
| [09 – Terraform destroy](./09-day-66-terraform-destroy.png) | Terraform-managed resources destroyed |
