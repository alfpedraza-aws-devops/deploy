PRIVATE_BUCKET_NAME=""
PRIVATE_MASTER_HOST=""
PRIVATE_TOKEN_VALUE=""
PRIVATE_TOKEN_HASH=""

function wait_for_master_ready() {
    # Wait for master until its state is running (i.e. not terminated).
    aws ec2 wait instance-running \
        --filters \
            "Name=tag:Name,Values=master" \
            "Name=instance-state-name,Values=pending,running"
    
    # Wait for master until its status is OK.
    local INSTANCE_ID=$(get_master_instance_id)
    aws ec2 wait instance-status-ok --instance-ids $INSTANCE_ID

    # Wait until the master node has been initialized and the K8S control plane is ready.
    # It waits 15 seconds, 40 times. That's 10 minutes.
    local TAGS=""
    for i in {1..40}; do
        PRIVATE_BUCKET_NAME=$(get_master_bucket_name $INSTANCE_ID)
        if [ ! -z "$PRIVATE_BUCKET_NAME" ]; then break; fi;
        sleep 15
    done
    if [ -z "$PRIVATE_BUCKET_NAME" ]; then echo "Master was not ready."; exit 1; fi;
}

function get_join_data() {
    # Download join data files from the specified bucket name in master.
    local BUCKET=$PRIVATE_BUCKET_NAME
    local REGION=$(get_region_name)
    aws s3 cp s3://$BUCKET/masterhost.txt /tmp/aws-devops/masterhost.txt --region $REGION
    aws s3 cp s3://$BUCKET/tokenvalue.txt  /tmp/aws-devops/tokenvalue.txt --region $REGION
    aws s3 cp s3://$BUCKET/tokenhash.txt /tmp/aws-devops/tokenhash.txt --region $REGION
    
    # Get the values from the temporal files.
    PRIVATE_MASTER_HOST=$(cat /tmp/aws-devops/masterhost.txt)
    PRIVATE_TOKEN_VALUE=$(cat /tmp/aws-devops/tokenvalue.txt)
    PRIVATE_TOKEN_HASH=$(cat /tmp/aws-devops/tokenhash.txt)

    # Remove temporal files.
    rm /tmp/aws-devops/masterhost.txt
    rm /tmp/aws-devops/tokenvalue.txt
    rm /tmp/aws-devops/tokenhash.txt
}

function join_cluster_implementation() {
    # Join to the Kubernetes master node.
    kubeadm join \
        $PRIVATE_MASTER_HOST \
        --token $PRIVATE_TOKEN_VALUE \
        --discovery-token-ca-cert-hash $PRIVATE_TOKEN_HASH
}

function join_cluster() {
    install_dependencies
    setup_kubelet "--node-labels=node-role.kubernetes.io/node="
    wait_for_master_ready
    get_join_data
    join_cluster_implementation
}

