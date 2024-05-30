#!/bin/bash

R="\e[31m"
Y="\e[32m"
G="\e[33m"
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

echo " Script executing at $TIMESTAMP" >> $LOGFILE 2>&1

if [ $ID -ne 0 ]
then
    echo "$R You are not a root user, login as root $N"
    exit 1
else
    echo "$G You are root user and executing script $N"
fi

apt list --installed 2>/dev/null | grep mysql-server 1>/dev/null >> $LOGFILE 2>&1

if [ $? -ne 0 ]
then
    apt install mysql-server -y
    VALIDATE "Mysql installation"
else
    echo "Mysql is already available... $Y Skipping$N"
fi

mysql_secure_installation -uroot -pRoboShop@1