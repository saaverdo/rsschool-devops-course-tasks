# RS DevOps Course
![CI Pipeline](https://github.com/saaverdo/rsschool-devops-course-tasks/actions/workflows/ci.yml/badge.svg)
---

## Task 1
### Requirements

terraform >= 1.10
aws account credentials available in sysytem [link](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration)
  

### General description

Terraform code located in `terraform/` directory:

```
terraform
├── core
│   ├── aws
│   │   ├── backend.tf
│   │   ├── iam_role.tf
│   │   ├── openid.tf
│   │   ├── outputs.tf.tf
│   │   ├── provider.tf
│   │   ├── terraform.tfvars
│   │   ├── variables.tf
│   │   └── versions.tf
│   └── tf_backend
│       ├── backend_bucket.tf
│       └── provider.tf
└── dev
    ├── backend.tf
    ├── ec2.tf
    ├── iam.tf
    ├── outputs.tf
    ├── provider.tf
    ├── s3.tf
    ├── sg.tf
    ├── terraform.tfvars
    ├── variables.tf
    └── versions.tf
```

`terraform/core/tf_backend` contains code for s3 bucked used for terraform state backend.  
This buckent was created by running terraform separately.
AWS IAM role for Github Actions `GithubActionsRole` with necessary permissions was created the same way by terraform code from `terraform/core/aws` dir.  

Actual infrastructure code lives in `terraform/dev` directory.  
It create EC2 instance, S3 bucket for backups, IAM role with instance profile for the EC2 instance to grant read-only access to the bucket and Security Group with ssh and http inbound rules.  

Normally workflow executed automatatically for pull requests and pushes to main branch.
Only `terraform plan` job executed for pull request, `terraform apply` runs after pull request approved and merged.


### Local run

To deploy code locally:  

clone repository  
switch to environment directory:  
```
cd terraform/dev
```
initialize terraform:  
```
terraform init
```
review planned changes:  
```
terraform plan
```
if everythong ok, apply infrastructure code:  
```
terraform apply
```


### Git hooks

To install pre-commit hook clone and enter repository directory, then run:  
```
./.git_hooks/_install_hook.sh
```

This hook require `shellcheck`, `tflint` and `terraform` to be installed in system.  
