

############################################################################
## ABOUT: Includes common functions for master and nodes configurations.  ##
############################################################################

function install_docker() {
    # Enable forwarding from Docker containers to the outside world.
    mkdir -p /etc/systemd/system/docker.service.d/
    printf "[Service]\nExecStartPost=/sbin/iptables -P FORWARD ACCEPT" | \
        tee /etc/systemd/system/docker.service.d/10-iptables.conf

    # Install docker: update the apt-get repository, install docker, print version.
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    apt-get update -y
    apt-get install -y docker-ce=17.03.2~ce-0~ubuntu-xenial
    docker version
}

function install_kubernetes() {
    # Update the apt-get repository.
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
    apt-add-repository 'deb http://apt.kubernetes.io/ kubernetes-xenial main'
    apt-get update -y

    # Install Kubernetes (kubernetes-cni, Kubelet, Kubeadm and Kubectl) and print versions.
    apt-get install -y kubernetes-cni=0.6.0-00
    apt-get install -y kubeadm=1.10.3-00 kubectl=1.10.3-00 kubelet=1.10.3-00
    kubeadm version
    kubelet --version
}

function install_awscli() {
    # Install AWS CLI: download unzip package, get aws zip file, unzip it and run installation.
    apt-get update -y
    apt-get install -y unzip
    mkdir -p /tmp/aws-devops
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/aws-devops/awscliv2.zip"
    unzip -qq /tmp/aws-devops/awscliv2.zip -d /home/ubuntu/
    rm /tmp/aws-devops/awscliv2.zip
    /home/ubuntu/aws/install
}

function install_dependencies() {
    # Install all the common dependencies.
    install_docker
    install_kubernetes
    install_awscli
}

