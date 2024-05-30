#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

timedatectl set-timezone Asia/Kolkata

TIMESTAMP=$(date +%F-%T)

LOGFILE="/redis/log/shell_script/$0-$TIMESTAMP.log"

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
        echo "$1 available...$Y Skipping $N"
    else
        mkdir -p $1
        $2
        $3
        echo "$1 created...$G Success $N"
    fi
}

DIR_CHECK "/frontend/log/shell_script"

echo " Script executing at $TIMESTAMP" >> $LOGFILE 2>&1

if [ $ID -ne 0 ]
then
    echo "$R You are not a root user, login as root $N"
    exit 1
else
    echo "$G You are root user and executing script $N"
fi

apt list --installed 2>/dev/null | grep redis-server 1>/dev/null

if [ $? -ne 0 ]
then
    echo " Redis is already available... $Y Skipping$N"
else
    apt update -y >> $LOGFILE 2>&1
    apt install redis-server -y >> $LOGFILE 2>&1
    echo " Redis is installing... $G Success$N"
fi

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf >> $LOGFILE 2>&1

VALIDATE "Enabled Redis to accept connections from all"

sed -i 's/protected-mode yes/protected-mode no/'  /etc/redis/redis.conf >> $LOGFILE 2>&1

VALIDATE "Disabled redis protection mode"

ystemctl daemon-reload >> $LOGFILE 2>&1

VALIDATE "Reloaded daemon service"

systemctl enable redis >> $LOGFILE 2>&1

VALIDATE "Enabled redis service"

systemctl start redis >> $LOGFILE 2>&1

VALIDATE "Started redis service"

systemctl restart redis >> $LOGFILE 2>&1

VALIDATE "Restarted redis service"