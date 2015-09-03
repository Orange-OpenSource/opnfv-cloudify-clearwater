#!/bin/bash -e

ctx logger debug "${COMMAND}"

ctx logger info "Configure the APT software source"
echo 'deb http://repo.cw-ngv.com/stable binary/' | sudo tee --append /etc/apt/sources.list.d/clearwater.list
curl -L http://repo.cw-ngv.com/repo_key | sudo apt-key add -
sudo apt-get update

ctx logger info "Installing bono packages and other clearwater packages"
sudo DEBIAN_FRONTEND=noninteractive apt-get install bono --yes --force-yes -o DPkg::options::=--force-confnew
sudo DEBIAN_FRONTEND=noninteractive apt-get install clearwater-config-manager --yes --force-yes
sudo DEBIAN_FRONTEND=noninteractive apt-get install clearwater-snmpd --yes --force-yes
ctx logger info "The installation packages is done correctly"

ctx logger info "Configure a new DNS server"
echo 'RESOLV_CONF=/etc/dnsmasq.resolv.conf' | sudo tee --append  /etc/default/dnsmasq
sudo service dnsmasq force-reload
ctx logger info "Installation is done"