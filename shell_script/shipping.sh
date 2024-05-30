#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

timedatectl set-timezone Asia/Kolkata

TIMESTAMP=$(date +%F-%T)

LOGFILE="/app/log/shell_script/$0-$TIMESTAMP.log"

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

DIR_CHECK () {
    if [ -d $1 ]
    then
        echo "$Y $1...available $N"
    else
        mkdir -p $1
        $2
        $3
        echo "$G $1...created $N"
    fi
}

DIR_CHECK "/app/log/shell_script/"

echo " Script executing at $TIMESTAMP" >> $LOGFILE 2>&1

if [ $ID -ne 0 ]
then
    echo "$R You are not a root user, login as root $N"
    exit 1
else
    echo "$G You are root user and executing script $N"
fi

DIR_CHECK /app

DIR_CHECK "/tmp/robot-shop" "git clone https://github.com/instana/robot-shop.git /tmp/robot-shop/" "cp -r /tmp/robot-shop/shipping/src/main/* /app" >> $LOGFILE 2>&1

cd /app

apt update -y

VALIDATE "Updating repos"

apt install default-jre -y

VALIDATE "Installation java"

apt install mavan -y

VALIDATE "Installation maven"