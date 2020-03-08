set -exuo pipefail

function main() {
    start_cluster
    share_join_data
    install_plugins
    echo "Success!"
}

main