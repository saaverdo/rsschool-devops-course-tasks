## Task 4. Jenkins
Jenkins Installation and Configuration in k8s cluster using HELM.
[Task description](https://github.com/rolling-scopes-school/tasks/blob/master/devops/modules/3_ci-configuration/task_4.md)
---

### Requirements
Locally installed  (`k3s` or `minikube`) or deployed on previous step k8s cluster.  
Current flow assuming using local one, but can be adapted to cloud environment.  

`kubectl` installed and can connect to the k8s cluster.  

All related code can be found in `./jenkins` directory  

### Prepare

clone repository and switch to jenkins directory:   
```bash
git clone git@github.com:saaverdo/rsschool-devops-course-tasks.git -b task_4
cd rsschool-devops-course-tasks/jenkins
```

install `helm`  

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

check if helm works correctly  
```bash
helm install test-helm oci://registry-1.docker.io/bitnamicharts/nginx
kubectl get all
```

by default nginx will be installed in `default` namespace  
if nginx chart was installed successfully, you'll see pod and services  
<details><summary>"kubectl get all" output</summary>

```
NAME                                   READY   STATUS    RESTARTS   AGE
pod/test-helm-nginx-8457797464-cd4c6   1/1     Running   0          7m28s

NAME                      TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)                      AGE
service/kubernetes        ClusterIP      10.43.0.1      <none>        443/TCP                      3d3h
service/test-helm-nginx   LoadBalancer   10.43.205.99   <pending>     80:32329/TCP,443:32493/TCP   7m28s

NAME                              READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/test-helm-nginx   1/1     1            1           7m28s

NAME                                         DESIRED   CURRENT   READY   AGE
replicaset.apps/test-helm-nginx-8457797464   1         1         1       7m29s
```

</details>

uninstall nginx as you don't need it more  
```bash
helm uninstall test-helm
```

### install Jenkins using HELM chart
[Source documentation](https://www.jenkins.io/doc/book/installing/kubernetes/#install-jenkins-with-helm-v3)  

add jenkins charts repo    

```bash
helm repo add jenkinsci https://charts.jenkins.io
helm repo update
```

create namespace for jenkins installation  
```bash
kubectl create namespace jenkins
```

create `PV` for jenkins data  
```bash
kubectl apply -f jenkins-01-volume.yaml
```
<details><summary>check if PV and SC config applied</summary>

```bash
kubectl get sc,pv
NAME                                               PROVISIONER                    RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
storageclass.storage.k8s.io/jenkins-pv             kubernetes.io/no-provisioner   Delete          WaitForFirstConsumer   false                  23s
storageclass.storage.k8s.io/local-path (default)   rancher.io/local-path          Delete          WaitForFirstConsumer   false                  3d3h

NAME                          CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
persistentvolume/jenkins-pv   20Gi       RWO            Retain           Available           jenkins-pv     <unset>                          23s

```

</details>


create service account  
```bash
kubectl apply -f jenkins-02-sa.yaml
```

Full list of chart values can be found in `jenkins-values-reference.yaml` file.  

All changes from defaults which are actually will be applied are placed into `jenkins-values.yaml` file.  

Key moments: service type set to `NodePort`, service account and persictent volume use previously created ones, additional user `rs-admin` will be created with initial password the same as `admin` and 2 jobs ``

Install jenkins chart:  
```sh
helm install jenkins -n jenkins -f jenkins-values.yaml jenkinsci/jenkins
```

<details><summary>command output</summary>

```
NAME: jenkins
LAST DEPLOYED: Sat Jul  5 22:50:07 2025
NAMESPACE: jenkins
STATUS: deployed
REVISION: 1
NOTES:
1. Get your 'admin' user password by running:
  kubectl exec --namespace jenkins -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo
2. Get the Jenkins URL to visit by running these commands in the same shell:
  export NODE_PORT=$(kubectl get --namespace jenkins -o jsonpath="{.spec.ports[0].nodePort}" services jenkins)
  export NODE_IP=$(kubectl get nodes --namespace jenkins -o jsonpath="{.items[0].status.addresses[0].address}")
  echo http://$NODE_IP:$NODE_PORT

3. Login with the password from step 1 and the username: admin
4. Configure security realm and authorization strategy
5. Use Jenkins Configuration as Code by specifying configScripts in your values.yaml file, see documentation: http://$NODE_IP:$NODE_PORT/configuration-as-code and examples: https://github.com/jenkinsci/configuration-as-code-plugin/tree/master/demos

For more information on running Jenkins on Kubernetes, visit:
https://cloud.google.com/solutions/jenkins-on-container-engine

For more information about Jenkins Configuration as Code, visit:
https://jenkins.io/projects/jcasc/


NOTE: Consider using a custom image with pre-installed plugins
```
</details>
In the output you can find commands examples to get admin's password and Jenkins' url  
however they won't work untill jenkins pod will finish init.  


check if pod starting:
```bash
kubectl get po -n jenkins
```

if status is not running, check logs of init container first   
```bash
kubectl logs pod/jenkins-0 -c init -n jenkins
```
Current PV configuration uses hostPath storage class, and default permissions for that directory are for root account only.  
It can be an issue.  
To fix it run:   
```bash
sudo chown -R 1000:1000 /data/jenkins-volume
```

now the jenkins pod should be up and running.  








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
#### setting up kubectl on the bastion host

From the bastion host run   
```
bash /tmp/deploy_kubectl.sh
```
this script will download `kubectl` and set up kube config in `~/.kube/config`  

#### Access cluster from local computer.
Install kubectl locally:

```
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

Get cluster configuration (it can be found in ssm parameter `/dev/k3s/config`) and save in into `~/.kube/k3s_config` to avoid rewriting existing config (if any)  
```
export KUBECONFIG=~/.kube/config:~/.kube/k3s_config
mkdir ~/.kube
aws ssm get-parameter --name "/dev/k3s/config" --region "eu-north-1" --with-decryption --query "Parameter.Value" --output text > ~/.kube/k3s_config
```

Create ssh tunnel to k3s master node through bastion host in separate terminal window:

ssh -L `<local_port>`:`<target host>`:`<target_port>` ubuntu@`<bastion_host>`   

example:  
```
ssh -L 6443:10.0.1.79:6443 ubuntu@51.21.127.55
```
Now you have access to the cluster  
```
kubectl get nodes
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
