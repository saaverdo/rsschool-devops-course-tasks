#!/bin/bash
apt-get update
apt-get install -y awscli 
curl -sfL https://get.k3s.io | sh -
# put k3s master token into ssm parameter
TOKEN_FILE=/var/lib/rancher/k3s/server/node-token
aws ssm put-parameter --name "/dev/k3s/node-token" --value file://$TOKEN_FILE --type "SecureString" --overwrite --region ${region}
# put k3s config into ssm parameter
KUB_CONFIG_FILE="/etc/rancher/k3s/k3s.yaml"
aws ssm put-parameter --name "/dev/k3s/config" --value file://$KUB_CONFIG_FILE --type "SecureString" --overwrite --region ${region}
echo "===== Finished Setup ====="