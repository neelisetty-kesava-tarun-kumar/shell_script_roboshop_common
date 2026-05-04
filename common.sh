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


echo "$(date "+%Y-%m-%d %H:%M:%S") | Script started at: $(date "+%Y-%m-%d %H:%M:%S")" | tee -a $LOGS_FILE

check_root(){
    if [ $USERID -ne 0 ]; then
        echo -e "$R Please run this script with root user access $N" | tee -a $LOGS_FILE
        exit 1 
    fi
}
mkdir -p $LOGS_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$(date "+%Y-%m-%d %H:%M:%S") | $2 ... $R FAILURE $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$(date "+%Y-%m-%d %H:%M:%S") | $2 ... $G SUCCESS $N" | tee -a $LOGS_FILE
    fi
}

print_total_time(){
    END_Time=$(date +%s)
    TOTAL_TIME=$(( $END_Time - $Start_Time ))
    echo -e "$(date "+%Y-%m-%d %H:%M:%S") | $Y Total time taken to execute the script: $TOTAL_TIME seconds $N" | tee -a $LOGS_FILE
}