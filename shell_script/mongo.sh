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

apt list --installed 2>/dev/null | grep mongod 1>/dev/null

if [ $? -ne 0 ]
then
    echo " Mongodb is not available and installing...$G Success $N"
    apt install gnupg curl -y >> $LOGFILE 2>&1
    curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor >> $LOGFILE 2>&1
    echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list >> $LOGFILE 2>&1
    apt update -y >> $LOGFILE 2>&1
    apt install -y mongodb-org >> $LOGFILE 2>&1
else
    echo " Mongodb is already available...$Y Skipping $N"
fi

sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf

VALIDATE "Chaned mongodb configuration"

systemctl restart mongod >> $LOGFILE 2>&1

VALIDATE "Restarted Nginx service"

DIR_CHECK "/tmp/robot-shop" "git clone https://github.com/instana/robot-shop.git /tmp/robot-shop/"

VALIDATE "Cloned mongo data"

systemctl daemon-reload >> $LOGFILE 2>&1

VALIDATE "Reloaded daemon service"

systemctl enable mongod >> $LOGFILE 2>&1

VALIDATE "Enabled Nginx service"

systemctl start mongod >> $LOGFILE 2>&1

VALIDATE "Started Nginx service"

systemctl restart mongod >> $LOGFILE 2>&1

VALIDATE "Restarted Nginx service"

mongosh --host localhost </tmp/robot-shop/mongo/users.js >> $LOGFILE 2>&1

VALIDATE "Loaded user data"

mongosh --host localhost </tmp/robot-shop/mongo/catalogue.js >> $LOGFILE 2>&1

VALIDATE "Loaded catalogue data"