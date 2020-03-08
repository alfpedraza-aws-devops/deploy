function setup_kubelet() {
    local KUBELET_EXTRA_ARGS=$1

    # Initialize hostname value from the AWS metadata service.
    local HOST_NAME=$(curl http://169.254.169.254/latest/meta-data/hostname)
    hostnamectl set-hostname $HOST_NAME
    hostnamectl status

    # Configures the Kubernetes Kubelet service to use the AWS cloud provider.
    # Setup the node-ip and configure the network plugin to cni.
    local NODE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
    printf "[Service]\nEnvironment=\"KUBELET_EXTRA_ARGS=--cloud-provider=aws --node-ip=$NODE_IP --authentication-token-webhook=true --authorization-mode=Webhook $KUBELET_EXTRA_ARGS\"" | \
        tee /etc/systemd/system/kubelet.service.d/20-aws.conf
    systemctl daemon-reload
    systemctl restart kubelet
}

function sign_kubelet_certificate() {
    local CA_CERT_PATH=$1
    local CA_KEY_PATH=$2

    # Create a CSR configuration file including the actual host name.
    local NODE_HOST_NAME=$(curl http://169.254.169.254/latest/meta-data/hostname)
    local NODE_CN="kubelet-$NODE_HOST_NAME"
    printf "[ req ]\ndefault_bits = 2048\nprompt = no\ndefault_md = sha256\nreq_extensions = req_ext\ndistinguished_name = dn\n\n[ dn ]\nCN = $NODE_CN\n\n[ req_ext ]\nsubjectAltName = @alt_names\n\n[ alt_names ]\nDNS = $NODE_HOST_NAME\n\n[ v3_ext ]\nbasicConstraints=CA:FALSE\nkeyUsage=keyEncipherment,digitalSignature\nextendedKeyUsage=serverAuth\nsubjectAltName=@alt_names\n" | \
        tee /tmp/aws-devops/csr.conf

    # Generates a private key, then the CSR, and finally the certificate signed with
    # the cluster private ca.key.
    openssl genrsa \
        -out /tmp/aws-devops/kubelet.key \
        2048
    openssl req -new \
        -key /tmp/aws-devops/kubelet.key \
        -config /tmp/aws-devops/csr.conf \
        -out /tmp/aws-devops/kubelet.csr
    openssl x509 -req \
        -in /tmp/aws-devops/kubelet.csr \
        -CA $CA_CERT_PATH \
        -CAkey $CA_KEY_PATH \
        -CAcreateserial \
        -days 360 \
        -extensions v3_ext \
        -extfile /tmp/aws-devops/csr.conf \
        -out /tmp/aws-devops/kubelet.crt

    # Replaces the kubelet "self-signed" certificate with the just created
    # certificate signed by the cluster private ca.key and ca.crt 
    mv /var/lib/kubelet/pki/kubelet.key /var/lib/kubelet/pki/kubelet.key.old
    mv /var/lib/kubelet/pki/kubelet.crt /var/lib/kubelet/pki/kubelet.crt.old
    cp /tmp/aws-devops/kubelet.crt /var/lib/kubelet/pki/kubelet.crt
    cp /tmp/aws-devops/kubelet.key /var/lib/kubelet/pki/kubelet.key

    # Restart kubelet so the changes can be applied.
    systemctl daemon-reload
    systemctl restart kubelet

    # Remove temporal files.
    rm /tmp/aws-devops/csr.conf
    rm /tmp/aws-devops/kubelet.key
    rm /tmp/aws-devops/kubelet.csr
    rm /tmp/aws-devops/kubelet.crt
}

function setup_kubectl() {
    # Copy the kubectl configuration file to HOME so it can be found in path.
    local ADMIN_CONFIG_PATH=$1
    mkdir -p /home/ubuntu/.kube
    cp -i $ADMIN_CONFIG_PATH /home/ubuntu/.kube/config
    chmod a+r /home/ubuntu/.kube/config
    export KUBECONFIG=/home/ubuntu/.kube/config
}

