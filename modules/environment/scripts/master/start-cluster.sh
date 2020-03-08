function start_cluster_implementation() {
    # Start Kubernetes cluster using a configuration file.
    printf 'apiVersion: kubeadm.k8s.io/v1alpha1\nkind: MasterConfiguration\ncloudProvider: aws\ntokenTTL: "0"' | \
        tee /tmp/aws-devops/kubeadm.config
    kubeadm init --config=/tmp/aws-devops/kubeadm.config
    rm /tmp/aws-devops/kubeadm.config
}

function install_cni_plugin() {
    # Install the amazon-vpc-cni-k8s daemon on the api server to allow pod networking.
    kubectl apply -f https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/master/config/v1.3/aws-k8s-cni.yaml
}

function start_cluster() {
    install_dependencies
    setup_kubelet ""
    start_cluster_implementation
    setup_kubectl "/etc/kubernetes/admin.conf"
    install_cni_plugin
}

