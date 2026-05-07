#!/bin/bash

source ./common.sh

APP_NAME="mysql"

check_root


dnf install mysql-server -y &>> $LOGS_FILE
VALIDATE $? "Installing MySQL Server"

systemctl enable mysqld &>> $LOGS_FILE
systemctl start mysqld
VALIDATE $? "Enabling and Starting MySQL service"

# Get the password from the User
mysql_secure_installation --set-root-pass RoboShop@1
VALIDATE $? "Setting up MySQL root password"

print_total_time