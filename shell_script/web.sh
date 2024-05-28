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

DIR_CHECK $LOGPATH

if [ $ID -ne 0 ]
then
    echo "$R You are not a root user, login as root $N"
    exit
else
    echo "$G You are root user and executing script $N"
    echo " Script executing at $TIMESTAMP" &>>$LOGFILE
fi

#apt update -y &>> $LOGFILE

#VALIDATE "Updating apt repositories"

apt list --installed 2>/dev/null | grep nginx 1>/dev/null

if [ $? -ne 0 ]
then
    echo "$Y Nginx is not available, installing $N"
    apt install nginx -y &>>$LOGFILE
else
    echo "$Y Nginx is already available $N"
    rm /etc/nginx/nginx.conf
fi

DIR_CHECK /frontend

DIR_CHECK "/tmp/robot-shop" "git clone https://github.com/instana/robot-shop.git /tmp/robot-shop/" "cp -r /tmp/robot-shop/web/static/ /frontend" &>>$LOGFILE

echo 'events{}
    http {
        include /etc/nginx/mime.types;

        server {
            listen 80;
            server_name localhost;

            root /frontend/static/;

            add_header Cache-Control public;
            add_header Pragma public;
            expires 1M;
        }
    }' >> /etc/nginx/nginx.conf &>>$LOGFILE

echo "$G Created Nginx configuration file $N"

systemctl daemon-reload &>>$LOGFILE

echo "$G Reloaded daemon service $N"

systemctl enable nginx &>>$LOGFILE

echo "$G Enabled Nginx service $N"

systemctl start nginx &>>$LOGFILE

echo "$G Started Nginx service $N"