function wait_for_node_ready() {
    # Wait until at least one worker node is described in the cluster as ready.
    for i in {1..40}; do
        local NODES="$(kubectl get nodes)"
        set +exuo pipefail; 
        local NODE_LINE=$(echo "$NODES" | grep "[[:space:]]\+Ready[[:space:]]\+node[[:space:]]\+" | head -1)
        set -exuo pipefail; 
        if [ ! -z "$NODE_LINE" ]; then break; fi;
        sleep 15
    done
    if [ -z "$NODE_LINE" ]; then echo "Couldn't wait for node ready."; exit 1; fi;
}

function install_helm() {
    # Install Helm
    mkdir /tmp/aws-devops/helm
    curl "https://get.helm.sh/helm-v2.7.2-linux-amd64.tar.gz" -o "/tmp/aws-devops/helm/helm.tar.gz"
    tar zxvf /tmp/aws-devops/helm/helm.tar.gz -C /tmp/aws-devops/helm/
    mv /tmp/aws-devops/helm/linux-amd64/helm /usr/local/bin/helm
    rm -r /tmp/aws-devops/helm/

    # Fix the tiller service
    export HELM_HOME=/home/ubuntu/.helm
    kubectl create serviceaccount --namespace kube-system tiller
    kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
    helm init --service-account tiller
    kubectl rollout status -w deployment/tiller-deploy --namespace=kube-system
}

function install_metrics_server_implementation() {
    # Install the metrics-server chart
    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm install \
        bitnami/metrics-server \
        --name metrics-server \
        --version 3.2.2 \
        --namespace kube-system \
        --set apiService.create=true
}

function install_metrics_server() {
    sign_kubelet_certificate \
        "/etc/kubernetes/pki/ca.crt" \
        "/etc/kubernetes/pki/ca.key"
    install_metrics_server_implementation
}

function install_cluster_autoscaler() {
    # Install the cluster-autoscaler service along with the kube2iam daemon.
    local ACCOUNT_ID=$(get_account_id)
    local REGION=$(get_region_name)
    local CLUSTER_NAME=$GLOBAL_CLUSTER_NAME
    local IAM_ROLE=$GLOBAL_CLUSTER_AUTOSCALER_ROLE_NAME
    local BASE_ROLE_ARN="arn:aws:iam::$ACCOUNT_ID:role/"

    helm repo add alfpedraza https://alfpedraza-aws-devops.github.io/helm-repository/
    helm install \
        alfpedraza/cluster-autoscaler \
        --name cluster-autoscaler \
        --version 0.1.0 \
        --set aws_region=$REGION,cluster_name=$CLUSTER_NAME,iam_role=$IAM_ROLE,base_role_arn=$BASE_ROLE_ARN
}

function install_kubernetes_dashboard() {
    # Install Kubernetes Dashbord though Helm
    helm repo add stable https://kubernetes-charts.storage.googleapis.com/
    helm install \
        stable/kubernetes-dashboard \
        --name kubernetes-dashboard \
        --version 1.10.1 \
        --set rbac.create=true,rbac.clusterAdminRole=true
}

function install_plugins() {
    wait_for_node_ready
    install_helm
    install_metrics_server  
    install_cluster_autoscaler
    install_kubernetes_dashboard
}