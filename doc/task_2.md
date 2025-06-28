## Task 3. K8s Cluster Configuration and Creation
### Requirements

terraform >= 1.10
aws account credentials available in system [link](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration)

### Description

All resources will be deployed in separate VPC.  
Details can be found in Task 2 description.  

Here Terraform code creates 3 hosts:

`bastion` - bastion server, the only entrypoint from the internet.  
`k3s_master` - k3s master node
`k3s_worker` - k3s worker node

All k3s nodes deployed in private subnets and only accessible from the bastion host.  
K3s cluster bootstrap is done with userdata scripts folowing official documentation [link](https://docs.k3s.io/quick-start).  
After setting up master node it's token saved in ssm parameter `/dev/k3s/node-token` and then used by worker node.  
Kube config and master node ip address are also saved in ssm parameters.  
They are needed to get access to k3s cluster from bastion host.  



#### start up setup locally

To deploy environment locally:  

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

Public IP address of the bastion host can be found in terraform outputs  
```
Apply complete! Resources: 0 added, 1 changed, 0 destroyed.

Outputs:

backup_bucket_name = "rs-devops-bsv-backup-bucket"
bastion_instance_external_ip = "51.21.127.55"
bastion_instance_internal_ip = "10.0.7.4"
```
Now you can connect to bastion host:  
```
ssh -J ubuntu@51.21.127.55
ubuntu@ip-10-0-7-4:~$
```
#### setting up kubectl

From the bastion host run   
```
bash /tmp/deploy_kubectl.sh
```
this script will download `kubectl` and set up kube config in `~/.kube/config`

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
│   ├── terraform.tfvars
│   ├── variables.tf
│   ├── versions.tf
│   └── vpc.tf
└── files
    └── bootstrap
        ├── deploy_app.sh
        ├── deploy_db.sh
        ├── deploy_k3s.tpl
        ├── deploy_kubectl.sh
        └── myapp.service
```

`terraform/core/` dir contains code for creation of s3 bucket for terraform state backend and 
AWS IAM role for Github Actions `GithubActionsRole` with necessary permissions.


Actual infrastructure code lives in `terraform/dev` directory.  

Normally workflow executed automatatically for pull requests and pushes to main branch.
Only `terraform plan` job executed for pull request, `terraform apply` runs after pull request approved and merged.
