#!/bin/bash

# Dirk van der Laarse
# 2022-05-22
# A script to start/stop/get status of an EC2 instance

instance=""
aws_cli_profile="default"
HORIZONTALLINE="------------------------------------------------------"
clear
echo $HORIZONTALLINE
echo -e "This script assists with starting/stopping EC2 Instances"

# Load list of AWS CLI Named Profiles
echo $HORIZONTALLINE
echo "Loading list of aws-cli profiles from ~/.aws/credentials ....."

aws_cli_profiles=($(grep '\[.*\]' ~/.aws/credentials))
profile_index=0
for each in "${aws_cli_profiles[@]}"
do
    count=$(($profile_index + 1))
    aws_cli_profile=$(echo "${aws_cli_profiles[profile_choice_index]}" | tr -d [])
    echo "$count: $each "
    (( profile_index++ ))
done
echo ""


# Get selected AWS Profile from user input
read -p "PLEASE SELECT AN AWS CLI PROFILE: " profile_choice

if [ "$profile_choice" -eq "$profile_choice" 2> /dev/null ]; then
    if [ $profile_choice -lt 1 -o $profile_choice -gt ${#aws_cli_profiles[@]} ]; then
        echo -e "\n==> Enter a number between 1 and ${#aws_cli_profiles[@]} <==";
    else
        profile_choice_index=$(($profile_choice - 1))
        aws_cli_profile=$(echo "${aws_cli_profiles[profile_choice_index]}" | tr -d [])
        echo "Selected: $aws_cli_profile"
    fi
else
    echo -e "\n==> This is not a number. Exiting. <=="
    exit 1
fi

# Load list of EC2 Instances using selected profile
echo $HORIZONTALLINE
echo "Loading list of EC2 Instances....."

instances=$(aws ec2 describe-instances --profile $aws_cli_profile)
echo $instances | jq '.Reservations[] | .Instances[] | .InstanceID as $InstanceID | {InstanceId, State} + ( .Tags[0] | {Value})'

echo -e "$HORIZONTALLINE\n"

INSTANCE_IDS=($(echo $instances | jq -r '.Reservations[] | .Instances[] | .InstanceId' | tr -d '[]," '))
INSTANCE_NAMES=($(echo $instances | jq -r '.Reservations[] | .Instances[] | .Tags[0] | .Value' | tr -d '[]," '))

index=0
for each in "${INSTANCE_IDS[@]}"
do
    count=$(($index + 1))
    echo "$count: $each (${INSTANCE_NAMES[index]}) "
    (( index++ ))
done

echo -e "$HORIZONTALLINE\n"

# Get selected EC2 instance from user input
read -p "PLEASE SELECT THE AWS EC2 Instance: " choice

if [ "$choice" -eq "$choice" 2> /dev/null ]; then
    if [ $choice -lt 1 -o $choice -gt ${#INSTANCE_IDS[@]} ]; then
        echo -e "\n==> Enter a number between 1 and ${#INSTANCE_IDS[@]} <==";
    else
        choice_index=$(($choice - 1))
        echo "Selected: ${INSTANCE_IDS[choice_index]} (${INSTANCE_NAMES[choice_index]})"
    fi
else
    echo -e "\n==> This is not a number. Exiting. <=="
    exit 1
fi

# Get required action from user input
echo $HORIZONTALLINE
echo -e "Possible Actions for $instance:"
echo "1. GET STATUS"
echo "2. START INSTANCE"
echo "3. STOP INSTANCE"
echo -e "$HORIZONTALLINE\n"

read -p "PLEASE CHOOSE AN ACTION: " action

if [ "$action" -eq "$action" 2> /dev/null ]; then
    if [ $action -lt 1 -o $action -gt 3 ]; then
        echo -e "\n==> Enter a number between 1 and 3 <=="
    elif [ $action -eq 1 ]; then
        aws ec2 describe-instance-status --instance-ids ${INSTANCE_IDS[choice_index]} --profile $aws_cli_profile
    elif [ $action -eq 2 ]; then
        aws ec2 start-instances --instance-ids ${INSTANCE_IDS[choice_index]} --profile $aws_cli_profile
    elif [ $action -eq 3 ]; then
        aws ec2 stop-instances --instance-ids ${INSTANCE_IDS[choice_index]} --profile $aws_cli_profile
    fi
else
    echo -e "\n==> This is not a number. Exiting. <=="
    exit 1
fi

