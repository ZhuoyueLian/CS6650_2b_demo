#!/bin/bash

# Script to get the public IP of your ECS task

echo "Fetching ECS task public IP..."

# Get the task ARN
TASK_ARN=$(aws ecs list-tasks --cluster product-service-cluster --region us-west-2 --query 'taskArns[0]' --output text)

if [ -z "$TASK_ARN" ] || [ "$TASK_ARN" == "None" ]; then
    echo "Error: No tasks found in the cluster. Is your service running?"
    exit 1
fi

echo "Task ARN: $TASK_ARN"

# Get ENI ID
ENI_ID=$(aws ecs describe-tasks --cluster product-service-cluster --tasks $TASK_ARN --region us-west-2 --query 'tasks[0].attachments[0].details[?name=='\''networkInterfaceId'\''].value' --output text)

if [ -z "$ENI_ID" ]; then
    echo "Error: Could not find network interface ID"
    exit 1
fi

echo "Network Interface ID: $ENI_ID"

# Get Public IP
PUBLIC_IP=$(aws ec2 describe-network-interfaces --network-interface-ids $ENI_ID --region us-west-2 --query 'NetworkInterfaces[0].Association.PublicIp' --output text)

if [ -z "$PUBLIC_IP" ]; then
    echo "Error: Could not find public IP"
    exit 1
fi

echo ""
echo "=========================================="
echo "Your API is available at:"
echo "http://$PUBLIC_IP:8080"
echo "=========================================="
echo ""
echo "Test endpoints:"
echo "curl http://$PUBLIC_IP:8080/health"
echo "curl \"http://$PUBLIC_IP:8080/products/search?q=electronics\""