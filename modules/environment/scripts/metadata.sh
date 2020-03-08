#!/bin/bash

function get_host_name() {
    curl http://169.254.169.254/latest/meta-data/hostname
}

function get_node_ip() {
    curl http://169.254.169.254/latest/meta-data/local-ipv4
}

function get_account_id() {
    curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | awk -F'"' '/\"accountId\"/ { print $4 }'
}

function get_region_name() {
    curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | awk -F'"' '/\"region\"/ { print $4 }'
}

function get_instance_id() {
    curl http://169.254.169.254/latest/meta-data/instance-id
}

function get_master_instance_id() {
    aws ec2 describe-instances \
        --filters \
            "Name=tag:Name,Values=$GLOBAL_MASTER_NAME" \
            "Name=instance-state-name,Values=running" \
        --query "Reservations[*].Instances[*].[InstanceId]" \
        --output text
}

function get_master_bucket_name() {
    local INSTANCE_ID=$1
    local TAGS="$(aws ec2 describe-tags \
        --filters "Name=resource-id,Values=$INSTANCE_ID" \
        --output text)"
    set +exuo pipefail; #Disable error checking
    local BUCKET_NAME=$(echo "$TAGS" | grep BUCKET_NAME | cut -f5)
    set -exuo pipefail; #Enable error checking
    echo $BUCKET_NAME
}