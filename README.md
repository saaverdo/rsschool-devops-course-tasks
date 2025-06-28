# RS DevOps Course
![CI Pipeline](https://github.com/saaverdo/rsschool-devops-course-tasks/actions/workflows/ci.yml/badge.svg)
---

## Task 2. Basic networking infrastructure
### Requirements

terraform >= 1.10
aws account credentials available in system [link](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration)

### Local run

To run locally:  

clone repository  
switch to environment directory (currently - `dev`):  
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

### Project layout

Terraform code is located in `terraform/` directory:

```
terraform
├── core
│   ├── aws
│       └── ...
│   └── tf_backend
│       └── ...
├── dev
│   ├── backend.tf
│   ├── ec2.tf
│   ├── iam.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── s3.tf
│   ├── sg.tf
│   ├── ssm_params.tf
│   ├── variables.tf
│   ├── versions.tf
│   └── vpc.tf
└── files
    └── bootstrap
        ├── deploy_app.sh
        ├── deploy_db.sh
        └── myapp.service
```

`terraform/core/` dir contains code for creation of s3 bucket for terraform state backend and 
AWS IAM role for Github Actions `GithubActionsRole` with necessary permissions.


Actual infrastructure code lives in `terraform/dev` directory.  

Resources:
`VPC` with 2 private and 2 public subnets in 2 AZs with managed NAT gateway.  

3 EC2 instances:  
  `web` - sample web app, placed in public subnet  
  `db` - mariadb database for awb app, placed in private subnet  
  `bastion` = bastion server, the only entrypoint from the internet.  

Access to these instances defined by respective `Security Groups`:  
  `sg_web` allows web traffic from the internet. Attached to `web` instance.  
  `sg_bastion` allows ssh traffic from the internet. Attached to `bastion` instance.  
  `sg_db` allows mysql traffic inside SG and any traffic from `sg_bastion`.  


Normally workflow executed automatatically for pull requests and pushes to main branch.
Only `terraform plan` job executed for pull request, `terraform apply` runs after pull request approved and merged.
