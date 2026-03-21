# Terraform: Multi-Compartment AWS Architecture

This directory contains Terraform code to build the **multi-compartment AWS architecture** from the design diagram: Internet compartment, GEN compartment, Workload compartments (X, Y, Z), Transit Gateway, and PrivateLink for system-to-system API consumption and exposure.

Any developer can run this in **any AWS account and region** by changing only configuration (Option A: Terraform variables + `.tfvars`).

---

## Table of contents

1. [Repository layout](#1-repository-layout)


## 1. Repository layout

```
terraform/
├── README.md                    # This file
├── environments/
│   └── dev/
│       ├── main.tf               # Root: TGW, VPCs, attachments, routes, PrivateLink
│       ├── variables.tf          # Variable definitions
│       ├── outputs.tf            # Outputs (VPC IDs, TGW ID, service names, etc.)
│       ├── locals.tf             # name_prefix, common_tags
│       ├── provider.tf           # AWS provider
│       ├── versions.tf           # Terraform & provider constraints
│       ├── backend.tf.example    # Example S3 backend (copy to backend.tf)
│       └── dev.tfvars            # Dev config (compartments, CIDRs, PrivateLink)
└── modules/
    
```

---
