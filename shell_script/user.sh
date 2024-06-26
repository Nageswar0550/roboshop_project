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

apt list --installed 2>/dev/null | grep nodejs 1>/dev/null

if [ $? -ne 0 ]
then
    echo " Nodejs is not available and installing...$G Success $N"
    apt update -y >> $LOGFILE 2>&1
    apt install nodejs -y >> $LOGFILE 2>&1
else
    echo " Nodejs is already available...$Y Skipping $N"
fi

id roboshop >> $LOGFILE 2>&1

if [ $? -ne 0 ]
then
    echo " User is not available, creating...$G Success$N"
    useradd -r roboshop
    exit
else
    echo " User already available... $Y Skipping $N"
fi

DIR_CHECK /app

DIR_CHECK "/tmp/robot-shop" "git clone https://github.com/instana/robot-shop.git /tmp/robot-shop/" "cp -r /tmp/robot-shop/user/*.js* /app" >> $LOGFILE 2>&1

apt list --installed 2>/dev/null | grep npm 1>/dev/null

if [ $? -ne 0 ]
then
    echo " Npm is not available and installing...$G Success $N"
    apt install npm -y >> $LOGFILE 2>&1
else
    echo " Npm is already available...$Y Skipping $N"
fi

cd /app && npm install >> $LOGFILE 2>&1

VALIDATE "Building and running app"

if [ -f "/etc/systemd/system/user.service" ]
then
    echo "user service file available...$Y Skipping$N"
else 
    echo '[Unit]
        Description=user service
        
        [Service]
        User=roboshop
        Environment=MONGO_URL=mongodb://172.31.18.210:27017/user
        Environment=REDIS_HOST=172.31.17.16
        ExecStart=/bin/node /app/server.js
        
        [Install]
        WantedBy=multi-user.target' > /etc/systemd/system/user.service
    echo "user service file created...$G Success$N"
fi

systemctl daemon-reload >> $LOGFILE 2>&1

VALIDATE "Reloaded daemon service"

systemctl enable user >> $LOGFILE 2>&1

VALIDATE "Enabled user service"

systemctl start user >> $LOGFILE 2>&1

VALIDATE "Started user service"

systemctl restart user >> $LOGFILE 2>&1

VALIDATE "Restarted user service"