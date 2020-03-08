set -exuo pipefail

function main() {
    join_cluster
    install_plugins
    echo "Success!"
}

main