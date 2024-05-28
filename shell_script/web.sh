#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

timedatectl set-timezone Asia/Kolkata

TIMESTAMP=$(date +%F-%T)

LOGFILE="/tmp/$0-$TIMESTAMP.log"

ID=$(id -u)

echo " Script executing at $TIMESTAMP" >> $LOGFILE 2>&1

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

if [ $ID -ne 0 ]
then
    echo "$R You are not a root user, login as root $N"
    exit 1
else
    echo "$G You are root user and executing script $N"
fi

#apt update -y >> $LOGFILE 2>&1

#VALIDATE "Updating apt repositories"

apt list --installed 2>/dev/null | grep nginx 1>/dev/null

if [ $? -ne 0 ]
then
    echo "Nginx is not available...$Y installing $N"
    apt install nginx -y >> $LOGFILE 2>&1
else
    echo "Nginx is already available...$Y Success$N"
    rm /etc/nginx/nginx.conf
fi

DIR_CHECK /frontend

DIR_CHECK "/tmp/robot-shop" "git clone https://github.com/instana/robot-shop.git /tmp/robot-shop/" "cp -r /tmp/robot-shop/web/static/ /frontend" >> $LOGFILE 2>&1

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
    }' >> /etc/nginx/nginx.conf >> $LOGFILE 2>&1

VALIDATE "Created Nginx configuration file"

systemctl daemon-reload >> $LOGFILE 2>&1

VALIDATE "Reloaded daemon service"

systemctl enable nginx >> $LOGFILE 2>&1

VALIDATE "Enabled Nginx service"

systemctl start nginx >> $LOGFILE 2>&1

VALIDATE "Started Nginx service"