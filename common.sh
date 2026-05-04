#Writing common functions for all the components

#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell_script_roboshop" # This variable is used to store the logs of the script in a specific folder, which is useful for troubleshooting and debugging purposes. The user can check the logs to see if there were any errors or issues during the execution of the script, and it can also be used to track the progress of the script. The user should ensure that they have the necessary permissions to create and write to this folder, and it is recommended to use a folder that is not easily accessible to unauthorized users for security reasons.
LOGS_FILE="$LOGS_FOLDER/$0.log"
R='\e[0;31m'
G='\e[0;32m'
Y='\e[0;33m'
N='\e[0m'
Start_Time=$(date +%s)
SCRIPT_DIR=$PWD
MONGODB_HOST="mongodb.kesavatarun.in"

mkdir -p $LOGS_FOLDER

echo "$(date "+%Y-%m-%d %H:%M:%S") | Script started at: $(date "+%Y-%m-%d %H:%M:%S")" | tee -a $LOGS_FILE

check_root(){
    if [ $USERID -ne 0 ]; then
        echo -e "$R Please run this script with root user access $N" | tee -a $LOGS_FILE
        exit 1 
    fi
}

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$(date "+%Y-%m-%d %H:%M:%S") | $2 ... $R FAILURE $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$(date "+%Y-%m-%d %H:%M:%S") | $2 ... $G SUCCESS $N" | tee -a $LOGS_FILE
    fi
}

nodejs_setup(){
    dnf module disable nodejs -y &>> $LOGS_FILE
    VALIDATE $? "Disabling NodeJS module" #Disabling the default NodeJS module to avoid conflicts with the version required by the application.

    dnf module enable nodejs:20 -y &>> $LOGS_FILE
    VALIDATE $? "Enabling NodeJS 20 module" #Enabling the NodeJS 20 module to ensure that the correct version of NodeJS is installed for the application.

    dnf install nodejs -y &>> $LOGS_FILE
    VALIDATE $? "Installing NodeJS" #Installing NodeJS

    npm install &>> $LOGS_FILE
    VALIDATE $? "Installing NodeJS dependencies for catalogue" #Installing the NodeJS dependencies for the application.

}

app_setup(){
    id roboshop &>> $LOGS_FILE
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $LOGS_FILE
        VALIDATE $? "Creating system user for roboshop" #Creating a system user for the application.
    else
        echo -e "$Y User roboshop already exists, skipping user creation $N" | tee -a $LOGS_FILE #If the user already exists, it will skip the user creation step and print a message indicating that the user already exists. This is useful to avoid errors or conflicts that may arise from trying to create a user that already exists, and it also helps to ensure that the script can be run multiple times without issues.
    fi

    mkdir -p /app 
    VALIDATE $? "Creating directory" #Creating a directory for the application to store its files and data.

    curl -o /tmp/$APP_NAME.zip https://roboshop-artifacts.s3.amazonaws.com/$APP_NAME-v3.zip &>> $LOGS_FILE
    VALIDATE $? "Downloading $APP_NAME code" #Downloading the application code from the specifed link and saving it as a zip file.

    cd /app
    VALIDATE $? "Moving to app directory"  #Changing the directory to /app to perform the subsequent operations related to the application setup.

    rm -rf /app/* 
    VALIDATE $? "Removing the existing $APP_NAME code if exists" #Removing the existing code from the /app directory to ensure a clean installation of the new code.

    unzip /tmp/$APP_NAME.zip &>> $LOGS_FILE 
    VALIDATE $? "Extracting or Unzip the $APP_NAME code" #Unzip the downloaded code to the /app directory.
}

system_setup(){
    cp $SCRIPT_DIR/$APP_NAME.service /etc/systemd/system/$APP_NAME.service
    VALIDATE $? "Copying systemctl service file for $APP_NAME" #Copying the systemctl service file for the application to the appropriate location, which allows the application to be managed as a service using systemctl commands.

    systemctl daemon-reload 
    systemctl enable $APP_NAME &>> $LOGS_FILE
    systemctl start $APP_NAME #Starting the $APP_NAME service using systemctl, which allows the application to run in the background and be automatically started on system boot.
    VALIDATE $? "Starting $APP_NAME service"
}

app_restart(){
    systemctl restart $APP_NAME
    VALIDATE $? "Restarting $APP_NAME service" #Restarting the $APP_NAME service to apply any changes made to the application or its configuration, ensuring that the latest version of the application is running.
}

print_total_time(){
    END_Time=$(date +%s)
    TOTAL_TIME=$(( $END_Time - $Start_Time ))
    echo -e "$(date "+%Y-%m-%d %H:%M:%S") | $Y Total time taken to execute the script: $TOTAL_TIME seconds $N" | tee -a $LOGS_FILE
}