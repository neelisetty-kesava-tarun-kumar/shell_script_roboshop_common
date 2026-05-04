#!/bin/bash

source ./common.sh
APP_NAME="catalogue"


check_root
app_setup
nodejs_setup
system_setup

#Loading the data into MongoDB server
cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongodb.repo
dnf install mongodb-mongosh -y &>> $LOGS_FILE
VALIDATE $? "Installing MongoDB Shell"

INDEX=$(mongosh --host $MONGODB_HOST --quiet --eval 'db.getMongo().getDBNames().indexOf("catalogue")')

if [ $INDEX -le 0 ]; then
    #echo -e "$Y catalogue database does not exist, inserting the data into MongoDB $N" | tee -a $LOGS_FILE
    mongosh --host $MONGODB_HOST </app/db/master-data.js &>> $LOGS_FILE
    VALIDATE $? "Inserting data into MongoDB"
else
    echo -e "$Y Catalogue database already exists, skipping data insertion into MongoDB $N" | tee -a $LOGS_FILE
fi

systemctl restart catalogue
VALIDATE $? "Restarting catalogue service"  