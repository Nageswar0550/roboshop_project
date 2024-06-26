#!/bin/bash

AMI=ami-0b4f379183e5706b9 #this keeps on changing
SG_ID=sg-0e159184a7bd00fd0 #replace with your SG ID
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "web")
ZONE_ID=Z10424741G2H2DBEZUCEI # replace your zone ID
DOMAIN_NAME="challa.cloud"

for i in "${INSTANCES[@]}"
do
    IP_ADDRESS=$(aws ec2 run-instances --image-id $AMI --instance-type t2.micro --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" --query 'Instances[0].PrivateIpAddress' --output text)

    echo "$i:$IP_ADDRESS"

    #create R53 record, make sure you delete existing record
    aws route53 change-resource-record-sets --hosted-zone-id $ZONE_ID --change-batch '
    {
        "Comment": "Creating a record set for cognito endpoint"
        ,"Changes": [{
        "Action"              : "UPSERT"
        ,"ResourceRecordSet"  : {
            "Name"              : "'$i'.'$DOMAIN_NAME'"
            ,"Type"             : "A"
            ,"TTL"              : 1
            ,"ResourceRecords"  : [{
                "Value"         : "'$IP_ADDRESS'"
            }]
        }
        }]
    }
        '
done

sleep 1m

for i in "${INSTANCES[@]}"
do
    echo -e "[$i]\n$i.$DOMAIN_NAME" >> inventory.ini
done  

echo -e "[all:vars]\nansible_ssh_pass=DevOps321" >> inventory.ini

ansible -i inventory.ini all -m shell -a "sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*" --become

ansible -i inventory.ini all -m shell -a "sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*" --become