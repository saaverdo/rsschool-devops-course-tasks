## Task 1
task description  
(https://github.com/rolling-scopes-school/tasks/blob/master/devops/modules/1_basic-configuration/task_1.md)  

### preparetion steps

These steps include aws cli and terraform app installation and setup,   
adding IAM user and attaching required policies.  

<details>
<summary>preparation steps details</summary>

Check aws cli version  
```
devops@gitlab:~$ aws --version
aws-cli/2.27.31 Python/3.13.3 Linux/5.15.0-107-generic exe/x86_64.ubuntu.22
```

check terraform version  
```
devops@gitlab:~$ terraform version
Terraform v1.12.1
on linux_amd64
```

Create user `"rs_admin"` in aws console > IAM  
Attach policies to user via cli:  

```
aws iam attach-user-policy \
    --policy-arn arn:aws:iam::aws:policy/<Policy_name> \
    --user-name <User_name>
```

Check policies attached to user:  
```
(venv) ✔ ~/rs/rsschool-devops-course-tasks/terraform [task_1 L|…4]
18:50 $ aws iam list-attached-user-policies --user-name  --profile terraform --output text
ATTACHEDPOLICIES        arn:aws:iam::aws:policy/AmazonRoute53FullAccess AmazonRoute53FullAccess
ATTACHEDPOLICIES        arn:aws:iam::aws:policy/AmazonEC2FullAccess     AmazonEC2FullAccess
ATTACHEDPOLICIES        arn:aws:iam::aws:policy/IAMFullAccess   IAMFullAccess
ATTACHEDPOLICIES        arn:aws:iam::aws:policy/AmazonSQSFullAccess     AmazonSQSFullAccess
ATTACHEDPOLICIES        arn:aws:iam::aws:policy/AmazonVPCFullAccess     AmazonVPCFullAccess
ATTACHEDPOLICIES        arn:aws:iam::aws:policy/AmazonS3FullAccess      AmazonS3FullAccess
ATTACHEDPOLICIES        arn:aws:iam::aws:policy/AmazonEventBridgeFullAccess     AmazonEventBridgeFullAccess
```

Configure aws cli with new user's access keys  
`aws configure` ...   

```
19:04 $ aws iam get-user --user-name rs_admin
{
    "User": {
        "Path": "/",
        "UserName": "rs_admin",
        "UserId": "AI*****************C",
        "Arn": "arn:aws:iam::6**********6:user/rs_admin",
        "CreateDate": "2025-06-09T18:37:57+00:00",
        "Tags": [
            {
                "Key": "AK*****************B",
                "Value": "IAC_key"
            }
        ]
    }
}
```

```
devops@gitlab:~$ aws ec2 describe-instance-types --instance-types t4g.nano --output text
INSTANCETYPES   True    False   True    True    False   False   True    nitro   False   t4g.nano        unsupported     supported       unsupported     supported
EBSINFO default supported       required
EBSOPTIMIZEDINFO        43      250     5.375   2085    11800   260.625
MEMORYINFO      512
NETWORKINFO     0       False   False   required        False   unsupported     2       2       True    1       2       Up to 5 Gigabit
NETWORKCARDS    0.032   2       2       0       Up to 5 Gigabit 5.0
SUPPORTEDVERSIONS       2.0
SUPPORTEDSTRATEGIES     partition
SUPPORTEDSTRATEGIES     spread
PROCESSORINFO   AWS     2.5
SUPPORTEDARCHITECTURES  arm64
SUPPORTEDBOOTMODES      uefi
SUPPORTEDROOTDEVICETYPES        ebs
SUPPORTEDUSAGECLASSES   on-demand
SUPPORTEDUSAGECLASSES   spot
SUPPORTEDVIRTUALIZATIONTYPES    hvm
VCPUINFO        2       1       2
VALIDCORES      1
VALIDCORES      2
VALIDTHREADSPERCORE     1
```

</details>

S3 bucket for terraform state created as one-shot action by terraform separately.  
This code placed into `terraform/core/tf_backend` dir.  

DynamoDB table for state lock now deprecated, switched to `use_lockfile = true` parameter.

AWS IAM role for Github Actions `GithubActionsRole` created by terraform code from `terraform/core/aws` dir.  


