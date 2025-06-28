#!/bin/bash

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
mkdir ~/.kube
aws ssm get-parameter --name "/dev/k3s/config" --region "eu-north-1" --with-decryption --query "Parameter.Value" --output text > ~/.kube/config
K3S_MASTER_IP=$(aws ssm get-parameter --name "/dev/k3s/master_ip" --region "eu-north-1" --with-decryption --query "Parameter.Value" --output text)
sed -i s"/127.0.0.1/$K3S_MASTER_IP/" ~/.kube/config
kubectl get nodes
echo "=== kubectl installed ==="
