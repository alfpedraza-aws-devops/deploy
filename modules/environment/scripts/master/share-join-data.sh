PRIVATE_MASTER_HOST=""
PRIVATE_TOKEN_VALUE=""
PRIVATE_TOKEN_HASH=""
PRIVATE_REGION_NAME=""
PRIVATE_BUCKET_NAME=""

function generate_join_data() {
    # Generate the values to share with the nodes so they can join the cluster later.
    local NODE_IP=$(get_node_ip)
    local TOKEN_HASH_VALUE=$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //')
    
    PRIVATE_MASTER_HOST=$NODE_IP:6443
    PRIVATE_TOKEN_VALUE=$(kubeadm token list | awk 'NR == 2 {print $1}')
    PRIVATE_TOKEN_HASH="sha256:$TOKEN_HASH_VALUE"
}

function create_s3_bucket() {
    # Create an AWS S3 bucket where the join data will be uploaded.
    local ACCOUNT_ID=$(get_account_id)
    local HOST_NAME=$(get_host_name)
    PRIVATE_REGION_NAME=$(get_region_name)
    PRIVATE_BUCKET_NAME="$ACCOUNT_ID-$GLOBAL_MASTER_NAME"
    local BUCKET_POLICY="{\"Version\": \"2012-10-17\",\"Id\": \"Policy1583629506118\",\"Statement\": [{\"Sid\": \"Stmt1583629432359\",\"Effect\": \"Allow\",\"Principal\": {\"AWS\": [\"arn:aws:iam::$ACCOUNT_ID:role/$GLOBAL_NODE_ROLE_NAME\",\"arn:aws:iam::$ACCOUNT_ID:role/$GLOBAL_JENKINS_ROLE_NAME\"]},\"Action\": [\"s3:GetObject\"],\"Resource\": [\"arn:aws:s3:::$PRIVATE_BUCKET_NAME/*\"]}]}"

    if [[ $(aws s3api list-buckets --query "Buckets[?Name == '$PRIVATE_BUCKET_NAME'].[Name]" --output text) = "$PRIVATE_BUCKET_NAME" ]]; then
        aws s3 rb s3://$PRIVATE_BUCKET_NAME --force
    fi
    
    aws s3api create-bucket \
        --bucket $PRIVATE_BUCKET_NAME \
        --region $PRIVATE_REGION_NAME \
        --create-bucket-configuration \
            LocationConstraint=$PRIVATE_REGION_NAME
    aws s3api wait bucket-exists
        --bucket $BUCKET_NAME
        --region $REGION_NAME
    aws s3api put-public-access-block \
        --bucket $PRIVATE_BUCKET_NAME \
        --region $PRIVATE_REGION_NAME \
        --public-access-block-configuration \
            "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
    aws s3api put-bucket-policy \
        --bucket $PRIVATE_BUCKET_NAME \
        --region $PRIVATE_REGION_NAME \
        --policy "$BUCKET_POLICY"
    aws s3api put-bucket-encryption \
        --bucket $PRIVATE_BUCKET_NAME \
        --region $PRIVATE_REGION_NAME \
        --server-side-encryption-configuration \
            '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
}

function upload_join_data() {
    # Stores the MasterHost, TokenValue and TokenHash values in temporal files.
    echo $PRIVATE_MASTER_HOST > /tmp/aws-devops/masterhost.txt
    echo $PRIVATE_TOKEN_VALUE > /tmp/aws-devops/tokenvalue.txt
    echo $PRIVATE_TOKEN_HASH > /tmp/aws-devops/tokenhash.txt

    # Stores the kubectl admin config file, the ca.crt and ca.key in temporal files.
    cp /etc/kubernetes/admin.conf /tmp/aws-devops/admin.conf
    cp /etc/kubernetes/pki/ca.crt /tmp/aws-devops/ca.crt
    cp /etc/kubernetes/pki/ca.key /tmp/aws-devops/ca.key
    chmod a+r /tmp/aws-devops/admin.conf
    chmod a+r /tmp/aws-devops/ca.crt
    chmod a+r /tmp/aws-devops/ca.key

    # Upload the files to the private S3 bucket.
    local BUCKET=$PRIVATE_BUCKET_NAME
    local REGION=$PRIVATE_REGION_NAME
    aws s3 cp /tmp/aws-devops/masterhost.txt s3://$BUCKET/ --region $REGION
    aws s3 cp /tmp/aws-devops/tokenvalue.txt s3://$BUCKET/ --region $REGION
    aws s3 cp /tmp/aws-devops/tokenhash.txt s3://$BUCKET/ --region $REGION
    aws s3 cp /tmp/aws-devops/admin.conf s3://$BUCKET/ --region $REGION
    aws s3 cp /tmp/aws-devops/ca.crt s3://$BUCKET/ --region $REGION
    aws s3 cp /tmp/aws-devops/ca.key s3://$BUCKET/ --region $REGION
    
    # Remove temporal files.
    rm /tmp/aws-devops/masterhost.txt
    rm /tmp/aws-devops/tokenvalue.txt
    rm /tmp/aws-devops/tokenhash.txt
    rm /tmp/aws-devops/admin.conf 
    rm /tmp/aws-devops/ca.crt
    rm /tmp/aws-devops/ca.key
}

function assign_instance_tag() {
    local INSTANCE_ID=$(get_instance_id)
    aws ec2 create-tags \
        --resources $INSTANCE_ID \
        --tags Key=BUCKET_NAME,Value=$PRIVATE_BUCKET_NAME
}

function share_join_data() {
    generate_join_data
    create_s3_bucket
    upload_join_data
    assign_instance_tag
}