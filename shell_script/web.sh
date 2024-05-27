#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%T)

LOGPATH="/root/log/shell_script"

LOGFILE="$LOGPATH/$0-$TIMESTAMP.log"


ID=$(id -u)

VALIDATE () {
    if [ $? -ne 0 ]
    then
        echo  " $1...$R FAILED $N"
        exit
    else
        echo " $1...$G SUCCESS $N"
    fi
}

if [ -d $LOGPATH ]
then
    echo "$Y Log path available $N"
else
    sudo mkdir -p $LOGPATH
fi

if [ $ID -ne 0 ]
then
    echo "$R You are not a root user, login as root $N"
    exit
else
    echo "$G You are root user and executing script $N"
    echo "Script executing at $TIMESTAMP" &>> $LOGFILE
fi

apt update -y &>> $LOGFILE

VALIDATE "Updating apt repositories"

apt list --installed &>/dev/null | grep nginx

if [ $? -ne 0 ]
then
    echo "$Y Nginx is not available, installing $N"
    apt install nginx -y &>> $LOGFILE
else
    echo "$G Nginx is already installed $N"
fi