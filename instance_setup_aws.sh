#!/bin/bash

# Set up variables
AMI="ami-0c94855ba95c71c99" # Change to the AMI of your choice
INSTANCE_TYPE="t2.micro"
KEY_NAME="my-key-pair" # Change to the name of your key pair
SECURITY_GROUP="my-security-group" # Change to the name of your security group

# Launch instance
INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI --instance-type $INSTANCE_TYPE --key-name $KEY_NAME --security-groups $SECURITY_GROUP --output text --query 'Instances[0].InstanceId')
echo "Instance launched with ID: $INSTANCE_ID"

# Wait for instance to be running
aws ec2 wait instance-running --instance-ids $INSTANCE_ID
echo "Instance is now running"

# Get instance public IP
PUBLIC_IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --output text --query 'Reservations[0].Instances[0].PublicIpAddress')
echo "Instance public IP address: $PUBLIC_IP"

# Install Julia
ssh -o StrictHostKeyChecking=no ec2-user@$PUBLIC_IP 'sudo yum -y update && sudo yum -y install julia'

# Install Plotly Dash
ssh -o StrictHostKeyChecking=no ec2-user@$PUBLIC_IP 'sudo /usr/local/bin/julia -e "import Pkg; Pkg.add(\"PlotlyJS\"); Pkg.add(\"Dash\"); Pkg.add(\"DataFrames\")"'

# Open port 1234
aws ec2 authorize-security-group-ingress --group-name $SECURITY_GROUP --protocol tcp --port 1234 --cidr 0.0.0.0/0
echo "Port 1234 is now open"

echo "Setup complete!"
