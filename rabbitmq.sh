#!/bin/bash

source ./common.sh

APP_NAME="rabbitmq"

check_root

cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
VALIDATE $? "Adding RabbitMQ repository file"

dnf install rabbitmq-server -y &>> $LOGS_FILE
VALIDATE $? "Installing RabbitMQ Server"

systemctl enable rabbitmq-server
systemctl start rabbitmq-server &>> $LOGS_FILE
VALIDATE $? "Enabling and Starting RabbitMQ service"

rabbitmqctl add_user roboshop roboshop123 &>> $LOGS_FILE
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOGS_FILE
VALIDATE $? "Creating RabbitMQ user and setting up permissions for roboshop"

print_total_time