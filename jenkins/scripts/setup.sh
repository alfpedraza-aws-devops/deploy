#!/bin/bash

# Install ansible 2.9.4
yum-config-manager --add-repo https://releases.ansible.com/ansible/rpm/release/epel-7-x86_64/
yum-config-manager --save --setopt=releases.ansible.com_ansible_rpm_release_epel-7-x86_64_.gpgkey=https://releases.ansible.com/keys/RPM-GPG-KEY-ansible-release.pub
yum install -y ansible-2.9.4-1.el7.ans.noarch

# Install git 2.18
yum-config-manager --add-repo http://opensource.wandisco.com/centos/7/git/x86_64/
yum-config-manager --save --setopt=opensource.wandisco.com_centos_7_git_x86_64_.gpgkey=http://opensource.wandisco.com/RPM-GPG-KEY-WANdisco
yum install -y git-2.18.0-1.WANdisco.402.x86_64

# Run the setup.yml Playbook to install all the required tools. 
ansible-pull \
    -U https://github.com/alfpedraza-aws-devops/deployment.git \
    -i jenkins/ansible/inventory.yml \
    jenkins/ansible/setup.yml
echo "Success!"