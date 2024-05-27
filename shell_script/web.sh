#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGPATH="/var/log/shell_script"
LOGFILE="$LOGPATH/$0.log"
DATE=$(date +%F-%T)
ID=$(id -u)

VALIDATE () {
    if [ $? -ne 0 ]
    then
        echo "$1...$R FAILED $N"
        exit 1
    else
        echo "$1...$G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo "$R You are not a root user, login as root $N"
    exit 1
else
    echo "$G You are root user and executing script $N"
    echo "Script executing at ${DATE}" &>>$LOGFILE
fi

apt update -y &>>$LOGFILE

VALIDATE $? "Updating apt repositories"

apt list --installed 2>/dev/null | grep nginx &>>$LOGFILE

if [ $? - ne 0 ]
then
    echo "Nginx is not available"
else
    echo "Installing Nginx"
    apt install nginx &>>$LOGFILE
    VALIDATE $? "Installing Nginx"
fi