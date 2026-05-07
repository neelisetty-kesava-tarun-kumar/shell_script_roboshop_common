#!/bin/bash

source ./common.sh
APP_NAME="frontend"
APP_DIR="/usr/share/nginx/html"

check_root

dnf module disable nginx -y &>> $LOGS_FILE
dnf module enable nginx:1.24 -y &>> $LOGS_FILE
dnf install nginx -y &>> $LOGS_FILE
VALIDATE $? "Installing Nginx"

systemctl enable nginx  &>> $LOGS_FILE
systemctl start nginx
VALIDATE $? "Enabling and Starting Nginx service"

rm -rf /usr/share/nginx/html/* 
VALIDATE $? "Removing default Nginx content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>> $LOGS_FILE
VALIDATE $? "Downloading frontend code"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>> $LOGS_FILE
VALIDATE $? "Extracting or Unzip the frontend code"

rm -rf /etc/nginx/nginx.conf

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf &>> $LOGS_FILE
VALIDATE $? "Copying Nginx configuration file"

systemctl restart nginx &>> $LOGS_FILE
VALIDATE $? "Restarting Nginx service"

print_total_time