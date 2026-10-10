# Day 66 -- Provision an EKS Cluster with Terraform

## Objective

Provision an Amazon EKS cluster using Terraform modules, connect with
`kubectl`, deploy Nginx with three replicas behind an AWS LoadBalancer,
verify the application, and destroy the lab infrastructure to avoid
ongoing charges.

## Environment

-   **AWS Region:** `ap-south-1` (Mumbai)
-   **EKS Cluster:** `terraweek-eks`
-   **Kubernetes Version:** `1.35`
-   **Worker Node Type:** `t3.medium`
-   **Desired Worker Nodes:** `2`
-   **VPC CIDR:** `10.0.0.0/16`
-   **Network:** Two public and two private subnets across two
    Availability Zones
-   **Nginx Replicas:** `3`

## Project Structure

Keep this Markdown file and the screenshot PNGs together in
`2026/day-66/`. The links below are relative to that directory.

``` text
2026/day-66/
├── README.md
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
    ├── providers.tf
    ├── vpc.tf
    ├── eks.tf
    ├── variables.tf
    ├── outputs.tf
    └── terraform.tfvars
```

## 1. Terraform Project Setup

Created the `terraform-eks/` directory and these files:

-   `providers.tf` -- Terraform/provider requirements and AWS provider.
-   `vpc.tf` -- VPC module configuration.
-   `eks.tf` -- EKS module and managed node group.
-   `variables.tf` -- Input variables.
-   `outputs.tf` -- Cluster name, endpoint, and region.
-   `terraform.tfvars` -- Lab-specific values.

**Screenshot:** [Project setup](01-day-66-project-setup.png)

## 2. VPC Configuration

Used the Terraform AWS VPC module to create a VPC with CIDR
`10.0.0.0/16`, two public subnets, two private subnets, an Internet
Gateway, route tables, DNS support, and one NAT Gateway. Kubernetes
subnet tags were configured for external and internal load balancers.

**Screenshot:** [VPC Terraform plan](02-day-66-vpc-terraform-plan.png)

## 3. EKS Module and Validation

Configured `terraform-aws-modules/eks/aws` with a managed node group
using `t3.medium` instances and the `AL2023_x86_64_STANDARD` AMI type.
Cluster creator administrator permissions were enabled for `kubectl`
access.

Commands used:

``` bash
terraform fmt
terraform init
terraform validate
terraform plan
```

**Screenshots:** - [EKS module
validation](03-day-66-eks-module-validation.png) - [EKS Terraform
plan](04-day-66-eks-terraform-plan.png) - [EKS version compatibility
check](05-day-66-eks-version-compatibility.png)

## 4. Provision the Infrastructure

Applied the reviewed configuration with:

``` bash
terraform apply
```

After reviewing the plan, confirmed with `yes`. Terraform reported:

``` text
Apply complete! Resources: 57 added, 0 changed, 0 destroyed.
```

**Screenshot:** [Terraform apply
completed](05-day-66-eks-terraform-apply.png)

## 5. Connect kubectl and Verify the Cluster

Updated the local kubeconfig:

``` bash
aws eks update-kubeconfig --region ap-south-1 --name terraweek-eks
kubectl get nodes
kubectl get pods -A
```

Both worker nodes reported `Ready`. The listed AWS networking, CoreDNS,
and kube-proxy pods were running with zero restarts at the time of
verification.

**Screenshot:** [EKS nodes and system
pods](06-day-66-eks-cluster-nodes-pods.png)

## 6. Deploy Nginx

Created `k8s/nginx-deployment.yaml` containing a Deployment with three
Nginx replicas and a `LoadBalancer` Service on port 80.

``` bash
kubectl apply -f ../k8s/nginx-deployment.yaml
kubectl get pods
kubectl get svc nginx-service
```

All three Nginx pods reached `Running` and `1/1 Ready`. The service
received an AWS load balancer hostname, and the default **"Welcome to
nginx!"** page was confirmed in a browser.

**Screenshots:** - [Nginx pods
running](07-day-66-nginx-pods-running.png) - [Nginx through the AWS
LoadBalancer](08-day-66-nginx-loadbalancer-browser.png)

## 7. Clean Up Resources

Deleted the Kubernetes resources first:

``` bash
kubectl delete -f ../k8s/nginx-deployment.yaml
kubectl get svc nginx-service
kubectl get svc
```

Confirmed that `nginx-service` was no longer found and only the default
`kubernetes` service remained. Then destroyed the Terraform
infrastructure:

``` bash
terraform destroy
```

Reviewed the plan and confirmed with `yes`. Terraform reported:

``` text
Destroy complete! Resources: 57 destroyed.
```

**Screenshot:** [Terraform destroy
completed](09-day-66-terraform-destroy.png)

## Outcome

-   Provisioned an EKS cluster and managed worker node group using
    Terraform modules.
-   Connected to the cluster with `kubectl`.
-   Verified worker nodes and Kubernetes system pods.
-   Deployed three Nginx replicas and exposed them using an AWS
    LoadBalancer.
-   Confirmed the Nginx welcome page was reachable.
-   Deleted Kubernetes resources and destroyed all 57 Terraform-managed
    resources.

## Cost and Cleanup Note

EKS, EC2 worker nodes, NAT Gateway, public IPv4 addresses, and load
balancers can incur charges while provisioned. Terraform reported that
all 57 managed resources were destroyed. As a final safety check, verify
in the AWS Console that no lab-related resources remain.

## Screenshot Index

  ---------------------------------------------------------------------------------------------
  Screenshot                                                Evidence
  --------------------------------------------------------- -----------------------------------
  [01 -- Project setup](01-day-66-project-setup.png)        Terraform directory and files

  [02 -- VPC plan](02-day-66-vpc-terraform-plan.png)        VPC module plan

  [03 -- EKS module                                         Terraform validation
  validation](03-day-66-eks-module-validation.png)          

  [04 -- EKS plan](04-day-66-eks-terraform-plan.png)        EKS infrastructure plan

  [05 -- Version                                            EKS version compatibility check
  compatibility](05-day-66-eks-version-compatibility.png)   

  [05 -- Terraform                                          Infrastructure creation completed
  apply](05-day-66-eks-terraform-apply.png)                 

  [06 -- Nodes and system                                   Worker nodes and system pods
  pods](06-day-66-eks-cluster-nodes-pods.png)               

  [07 -- Nginx pods](07-day-66-nginx-pods-running.png)      Three Nginx replicas running

  [08 -- Nginx browser                                      Nginx reachable via LoadBalancer
  test](08-day-66-nginx-loadbalancer-browser.png)           

  [09 -- Terraform                                          All Terraform-managed resources
  destroy](09-day-66-terraform-destroy.png)                 destroyed
  ---------------------------------------------------------------------------------------------
