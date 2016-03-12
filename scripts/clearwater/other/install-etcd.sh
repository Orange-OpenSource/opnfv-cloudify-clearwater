#!/bin/bash -e

ctx logger debug "${COMMAND}"

ctx logger info "Configure the APT software source"
echo 'deb http://repo.cw-ngv.com/stable binary/' | sudo tee --append /etc/apt/sources.list.d/clearwater.list
curl -L http://repo.cw-ngv.com/repo_key | sudo apt-key add -
sudo apt-get update

ctx logger info "Now install the software"
sudo DEBIAN_FRONTEND=noninteractive apt-get install clearwater-management --yes --force-yes
ctx logger info "The software is installed"

sudo /usr/share/clearwater/clearwater-config-manager/scripts/upload_shared_config
# sudo /usr/share/clearwater/clearwater-config-manager/scripts/apply_shared_config

ctx logger info "Installation is done"
