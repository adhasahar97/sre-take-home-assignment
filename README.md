# Feedme SRE Take Home Assignment

## Tech Stack

- EKS cluster for container orchestration
- AWS Network Loadbalancer for secure external access
- Terraform for infrastructure provisioning and management
- ArgoCD for GitOps-based continuous delivery
- GitHub Actions for building docker images and running automations
- Cloudflare for DNS management

## Deployment Diagram
```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│                 │     │                 │     │                 │
│  User           │────▶│  AWS ELB        │────▶│  Kubernetes     │ ◄───
│  Network Route  │     │  Load Balancer  │     │  Cluster        │     │
└─────────────────┘     └─────────────────┘     └─────────────────┘     │
                                                         │              │
                                                         ▼              │
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐     │
│                 │     │                 │     │                 │     │
│  GitHub Repo    │────▶│  ArgoCD         │────▶│  Applications   │     │
│  App Deployment │     │  GitOps         │     │  & Services     │     │
└─────────────────┘     └─────────────────┘     └─────────────────┘     │
                                                                        │
                                                                        │
┌─────────────────┐              ┌─────────────────┐                    │
│                 │              │                 │                    │
│  GitHub Actions │─────────────▶│  Terraform      │────────────────────
│  Infrastructure │              │  GitOps         │ 
|  Provisioning   |              |                 |
└─────────────────┘              └─────────────────┘     

```

## Pre-requisites
Before setting up this project, ensure you have the following:

- AWS Account.
- IAM User or Role with AdmininstratorAccess policy.
- AWS S3 bucket for storing Terraform statefile. [Configuring Terraform backend to use S3 Bucket](https://developer.hashicorp.com/terraform/language/backend/s3)

For this Feedme SRE Assessment, OIDC is used for granting GitHub Actions access to AWS API.
Below is the IAM Role trust relationship when setting up this OIDC
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::955059924186:oidc-provider/token.actions.githubusercontent.com"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
                },
                "StringLike": {
                    "token.actions.githubusercontent.com:sub": "repo:adhasahar97/sre-take-home-assignment:*"
                }
            }
        }
    ]
}
```

This Github Actions step is used to auth against OIDC
```yaml
 - name: Configure AWS Credentials
   uses: aws-actions/configure-aws-credentials@v4.1.0
   with:
      aws-region: ap-southeast-1
      role-to-assume: arn:aws:iam::955059924186:role/terraform-admin-role
      role-session-name: terraform-session
```

## Provisioning the infrastructure for hosting the project
The infrastructure will be deployed declaratively using Terraform for reproducibility. The project files are located in `infra/terraform`. For this specific deployment, the entrypoint for the Terraform script is in `infra/terraform/aws`.

Stack that will be deployed by the Terraform Script:
1. AWS Services
   - VPC, Subnet
   - EKS in Auto Mode
   - Role/User assignment to EKS
2. Softwares
   - ArgoCD - for deploying the application in EKS
   - Ingress-Nginx - for serving/exposing the application to the internet
   - Grafana,Prometheus,Loki,Alloy - for monitoring

Run [Terraform AWS workflow](https://github.com/adhasahar97/sre-take-home-assignment/blob/main/.github/workflows/terraform-aws.yaml) to start provisioning the infrastructre. The Terrafrm codes are located in `infra/terraform` folder. 
The workflow also will be automatically triggered when there is a new commit in `infra/terraform` directories in a `main` branch.

## Updating and building the code
A GitHub Actions workflow called [Build and Push Docker Images](https://github.com/adhasahar97/sre-take-home-assignment/blob/main/.github/workflows/docker-build.yml) is used to build the Docker images for the frontend and backend.
The workflow is triggered when a tag is created like "v1.0.4". It must follow semantic versioning format. The Docker images will be published here:
- [Feedme frontend Docker image](https://hub.docker.com/repository/docker/adhasahar/feedme-sre-frontend/general)
- [Feedme backend Docker image](https://hub.docker.com/repository/docker/adhasahar/feedme-sre-backend/general)

## Upgrading deployment version in Kubernetes
Kustomize is being used as a templating engine for the application to streaming line the deployment process.

The `frontend` and `backend` can be upgraded by chaging the tag version in [`infra/argocd/feedme/kustomization`](https://github.com/adhasahar97/sre-take-home-assignment/blob/main/infra/argocd/feedme/kustomization.yaml):
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- deployment-fe.yaml
- deployment-be.yaml
- deployment-mongodb.yaml
- service-fe.yaml
- service-be.yaml
- service-mongodb.yaml
- ingress.yaml
- servicemonitor.yaml
images:
- name: adhasahar/feedme-sre-frontend
  newTag: 1.0.7 ## <--------- Change this value
- name: adhasahar/feedme-sre-backend
  newTag: 1.0.7 ## <--------- Change this value
```

Once changed, do push the changes to GitHub and ArgoCD will automatically picked up the changes.