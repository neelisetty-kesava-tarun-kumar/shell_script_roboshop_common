#!/bin/bash

source ./common.sh

check_root

cp mongo.repo /etc/yum.repos.d/mongodb.repo
VALIDATE $? "Copying MongoDB repo file"

dnf install mongodb-org -y &>> $LOGS_FILE
VALIDATE $? "Installing MongoDB Server"

systemctl enable mongod &>> $LOGS_FILE
VALIDATE $? "Enabling MongoDB Service"

systemctl start mongod
VALIDATE $? "Starting MongoDB Service"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Allowing remote connections to MongoDB"

systemctl restart mongod
VALIDATE $? "Restarting MongoDB Service"

print_total_time