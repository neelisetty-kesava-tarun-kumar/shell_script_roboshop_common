#!/bin/bash

source ./common.sh
APP_NAME="redis"
check_root

dnf module disable redis -y &>> $LOGS_FILE
dnf module enable redis:7 -y &>> $LOGS_FILE
VALIDATE $? "Enabling Redis 7 module" #Enabling Redis 7 module to ensure we install the latest version of Redis server

dnf install redis -y &>> $LOGS_FILE
VALIDATE $? "Installing Redis" #Installing Redis server 

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf &>> $LOGS_FILE
VALIDATE $? "Updating Redis configuration to allow remote connections and disable protected mode" #Updating Redis configuration to allow remote connections and disable protected mode

systemctl enable redis  &>> $LOGS_FILE
systemctl start redis  #Starting Redis service
VALIDATE $? "Enable and Starting Redis service" #Enabling and starting the Redis service to ensure it is running correctly

print_total_time