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
    echo " Script executing at $TIMESTAMP" &>> $LOGFILE
fi

#apt update -y &>> $LOGFILE

#VALIDATE "Updating apt repositories"

apt list --installed 2>/dev/null | grep nginx 1>/dev/null

if [ $? -ne 0 ]
then
    echo "$Y Nginx is not available, installing $N"
    apt install nginx -y &>> $LOGFILE
    mv /etc/nginx/nginx.conf /etc/nginx/nginx.backup.conf
else
    echo "$G Nginx is already available $N"
fi

if [ -d /web ]
then
    echo "$Y /web directory already available $N"
else
    mkdir /web
    echo "$G /web directory created $N"
fi

git clone https://github.com/instana/robot-shop.git /tmp/
mv /tmp/robot-shop/web/scripts/ /web/

VALIDATE "Cloning ang copying frontend data"