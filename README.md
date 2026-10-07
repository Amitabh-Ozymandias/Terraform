# Session 18 — Terraform S3 Demo

Provision an **AWS S3 bucket** with Terraform and walk through the complete Terraform workflow:
`init → fmt → validate → plan → apply → show → output → destroy`.

Terminal output from each command run is in [submission.md](submission.md).

## Project Structure

```text
terraform-s3-demo/
├── main.tf             # S3 bucket + versioning + public access block
├── variables.tf        # Input variable definitions
├── outputs.tf          # Values printed after apply
├── provider.tf         # Terraform settings + AWS provider
├── terraform.tfvars    # Values for the variables
├── README.md           # This file
├── submission.md       # Command runs + screenshots
└── aws-services/       # Task 2 – AWS service research notes
```

| File | Purpose |
|---|---|
| `provider.tf` | Pins Terraform `>= 1.6.0` and the `hashicorp/aws ~> 6.0` provider; configures the region from `var.aws_region`. |
| `variables.tf` | Declares `aws_region`, `bucket_name`, `environment`. |
| `terraform.tfvars` | Supplies actual values (region `ap-southeast-2`, bucket name, environment). |
| `main.tf` | `aws_s3_bucket.demo`, `aws_s3_bucket_versioning.demo` (Enabled), `aws_s3_bucket_public_access_block.demo` (all public access blocked). |
| `outputs.tf` | `bucket_name`, `bucket_arn`, `bucket_region`, `versioning_status`. |

## How the Files Fit Together

```text
terraform.tfvars ──▶ variables.tf ──▶ provider.tf (region)
                                   └─▶ main.tf ──▶ AWS S3 bucket
                                                     ├─ versioning
                                                     └─ public access block
                                         │
                                         ▼
                                    outputs.tf ──▶ terraform output
```

## Prerequisites

Run in WSL (Ubuntu):

```bash
terraform version          # Terraform v1.13.x
aws --version              # AWS CLI v2
aws configure              # Access key, secret key, region
aws sts get-caller-identity
```

> S3 bucket names are **globally unique**. If `apply` fails with `BucketAlreadyExists`, change `bucket_name` in `terraform.tfvars`.

## Terraform Workflow

All commands are run from:

```text
amitabh@LAPTOP-3KF17VR3:/mnt/c/Users/USER/Downloads/terraform-s3-demo$
```

### 1. `terraform init`
Initializes the working directory: downloads the AWS provider into `.terraform/` and records the exact version in `.terraform.lock.hcl`.
Expected: `Terraform has been successfully initialized!`

### 2. `terraform fmt`
Rewrites `.tf` files to the canonical style (indentation, aligned `=`). It prints the names of the files it changed and nothing if everything is already formatted. Use `terraform fmt -check` in CI.

### 3. `terraform validate`
Checks that the configuration is syntactically valid and internally consistent (types, references, required arguments). It does not contact AWS.
Expected: `Success! The configuration is valid.`

### 4. `terraform plan`
Compares the configuration with the current state and real infrastructure, then shows what will change.
Expected: `Plan: 3 to add, 0 to change, 0 to destroy.`

Symbols: `+` create, `~` update in place, `-` destroy, `-/+` replace.

### 5. `terraform apply`
Shows the plan again and asks for confirmation. Type `yes`. Terraform creates the bucket, then the versioning and public-access-block resources (they depend on the bucket ID), and writes `terraform.tfstate`.
Expected: `Apply complete! Resources: 3 added, 0 changed, 0 destroyed.` followed by the outputs.

### 6. `terraform show`
Prints the current state in human-readable form, including every attribute AWS returned (ARN, region, hosted zone ID, tags…).

### 7. `terraform output`
Prints the output values from the state. `terraform output bucket_name` prints a single output, and `-json` gives machine-readable output.

### 8. Verify with the AWS CLI (optional)
```bash
aws s3 ls | grep yatri1107
aws s3api get-bucket-versioning --bucket yatri1107-session18-tf-demo
```

### 9. `terraform destroy`
Plans the deletion of every resource in the state and asks for confirmation. Type `yes`.
Expected: `Destroy complete! Resources: 3 destroyed.`
`force_destroy = true` lets Terraform delete the bucket even if it still contains objects.

## Command Summary

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform show
terraform output
terraform destroy
```

## Terraform Lifecycle

```text
 write .tf ─▶ init ─▶ fmt ─▶ validate ─▶ plan ─▶ apply ─▶ show / output ─▶ destroy
                                          ▲        │
                                          └────────┘  (edit config, plan again)
```

## Key Concepts

- **Provider** – plugin that talks to an API (here AWS).
- **Resource** – a piece of infrastructure Terraform manages (`aws_s3_bucket`).
- **Variable / tfvars** – parameterize the configuration without editing code.
- **Output** – exported values after apply.
- **State (`terraform.tfstate`)** – Terraform's record of what it created. It is not committed to git (see `.gitignore`); teams store it in a remote backend (S3 + locking).
- **Lock file (`.terraform.lock.hcl`)** – pins provider versions. It should be committed.
