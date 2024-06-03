#!/bin/bash

INSTANCE_NAME=("web", "mongo", "mysql", "rabbitmq", "catalogue", "user", "cart", "shipping", "payment")

for ( i in $INSTANCE_NAME[@] )
do
    aws ec2 run-instances --image-id ami-04b70fa74e45c3917 --count 9 --instance-type t2.micro --security-group-ids sg-0e159184a7bd00fd0 --key-name Lenovo
done