PRIVATE_BUCKET_NAME=""
PRIVATE_REGION_NAME=""

function get_bucket_name() {
    local MASTER_INSTANCE_ID=$(get_master_instance_id)
    PRIVATE_BUCKET_NAME=$(get_master_bucket_name $MASTER_INSTANCE_ID)
    PRIVATE_REGION_NAME=$(get_region_name)
}

function sign_kubelet() {
    # Sign the kubelet certificate.
    local BUCKET=$PRIVATE_BUCKET_NAME
    local REGION=$PRIVATE_REGION_NAME
    aws s3 cp s3://$BUCKET/ca.crt /tmp/aws-devops/ca.crt --region $REGION
    aws s3 cp s3://$BUCKET/ca.key /tmp/aws-devops/ca.key --region $REGION
    sign_kubelet_certificate \
        "/tmp/aws-devops/ca.crt" \
        "/tmp/aws-devops/ca.key"
    rm /tmp/aws-devops/ca.crt
    rm /tmp/aws-devops/ca.key
}

function setup_the_kubectl() {
    local BUCKET=$PRIVATE_BUCKET_NAME
    local REGION=$PRIVATE_REGION_NAME
    aws s3 cp s3://$BUCKET/admin.conf /tmp/aws-devops/admin.conf --region $REGION
    setup_kubectl "/tmp/aws-devops/admin.conf"
    rm /tmp/aws-devops/admin.conf 
}

function install_plugins() {
    get_bucket_name
    sign_kubelet
    setup_the_kubectl
}