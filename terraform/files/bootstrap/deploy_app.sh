#!/bin/bash
set -e
# APP_DIR=${1:-$HOME}
APP_DIR=""
sudo apt-get install -y git python3-pip
git clone https://github.com/saaverdo/flask-alb-app -b orm $APP_DIR/flask-alb-app
cd $APP_DIR/flask-alb-app
pip install -r requirements.txt
DB_HOST=$(aws ssm get-parameter --name /dev/db/MYSQL_HOST --region $AWS_REGION --query "Parameter.Value" --output text)
sed -i s/{db_host}/$DB_HOST/ /tmp/myapp.service
sudo mv /tmp/myapp.service /etc/systemd/system/myapp.service
sudo systemctl daemon-reload
sudo systemctl start myapp
sudo systemctl enable myapp