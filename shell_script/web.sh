#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

timedatectl set-timezone Asia/Kolkata

TIMESTAMP=$(date +%F-%T)

LOGFILE="/frontend/log/shell_script/$0-$TIMESTAMP.log"

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

apt update -y >> $LOGFILE 2>&1

VALIDATE "Updating apt repositories"

apt list --installed 2>/dev/null | grep nginx 1>/dev/null

if [ $? -ne 0 ]
then
    echo " Nginx is not available and installing...$G Success $N"
    apt install nginx -y >> $LOGFILE 2>&1
    rm /etc/nginx/nginx.conf
else
    echo " Nginx is already available...$Y Skipping $N"
fi

DIR_CHECK /frontend

DIR_CHECK "/tmp/robot-shop" "git clone https://github.com/instana/robot-shop.git /tmp/robot-shop/" "cp -r /tmp/robot-shop/web/static/ /frontend"

if [ -f "/etc/nginx/nginx.conf" ]
then
    echo "Nginx config file available...$Y Skipping$N"
else 
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
        }' >> /etc/nginx/nginx.conf
        echo "Nginx config file created...$G Success$N"
fi

VALIDATE "Created Nginx configuration file"

systemctl daemon-reload >> $LOGFILE 2>&1

VALIDATE "Reloaded daemon service"

systemctl enable nginx >> $LOGFILE 2>&1

VALIDATE "Enabled Nginx service"

systemctl start nginx >> $LOGFILE 2>&1

VALIDATE "Started Nginx service"

systemctl start nginx >> $LOGFILE 2>&1

VALIDATE "Restarted Nginx service"