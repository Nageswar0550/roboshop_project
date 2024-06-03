#!/bin/bash

INSTANCE_NAME={"web","mongo","mysql","rabbitmq","catalogue","user","cart","shipping","payment"}

for  i in "${INSTANCE_NAME[@]}"
do
    if $i -eq "web"
    then
        aws ec2 run-instances --image-id ami-04b70fa74e45c3917 --instance-type t2.micro --security-group-ids sg-0e159184a7bd00fd0 --key-name Lenovo --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" --query 'Instances[0].PublicIpAddress' --output text
    else
        aws ec2 run-instances --image-id ami-04b70fa74e45c3917 --instance-type t2.micro --security-group-ids sg-0e159184a7bd00fd0 --key-name Lenovo --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" --query 'Instances[0].PrivateIpAddress' --output text
    fi
done