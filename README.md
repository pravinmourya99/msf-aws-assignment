# MSF Assignment – Multi-Compartment AWS Architecture

This repository implements the **multi-compartment AWS architecture** (Internet, GEN, Workload X/Y/Z, Transit Gateway, PrivateLink) using **Terraform**, with config-driven design so any developer can run it in any AWS account by changing only configuration.

## Quick start

1. **Prerequisites:** Terraform ≥ 1.5, AWS CLI (or credentials) for the target account.
2. **Configure:** Edit `terraform/environments/dev/dev.tfvars` and set `project`, `environment`, `aws_region`, and subnet availability zones for your region.
3. **Apply:**
   ```bash
   cd terraform/environments/dev
   terraform init
   terraform plan -var-file=dev.tfvars
   terraform apply -var-file=dev.tfvars
   ```
