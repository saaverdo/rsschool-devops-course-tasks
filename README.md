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

```

`terraform/core/tf_backend` contains code for s3 bucked used for terraform state backend.  
This buckent was created by running terraform separately.

AWS IAM role for Github Actions `GithubActionsRole` eith necessary permissions was created the same way by terraform code from `terraform/core/aws` dir.  

Actual infrastructure code lives in `terraform/dev` directory.  

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
