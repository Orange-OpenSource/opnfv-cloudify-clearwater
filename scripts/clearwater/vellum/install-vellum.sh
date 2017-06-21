#!/bin/bash -e

ctx logger debug "${COMMAND}"


sudo mkdir -p /etc/chronos

echo '
[http]
bind-address = $(hostname -I)
bind-port = 7253
threads = 50

[logging]
folder = /var/log/chronos
level = 2

[alarms]
enabled = true

[exceptions]
max_ttl = 600' | sudo tee --append /etc/chronos/chronos.conf


release=$(ctx node properties release)

ctx logger info "Configure the APT software source"
if [ ! -f /etc/apt/sources.list.d/clearwater.list ]
  then
    if [ $release = "stable" ]
    then
      echo 'deb http://repo.cw-ngv.com/stable binary/' | sudo tee --append /etc/apt/sources.list.d/clearwater.list
    else
      echo "deb http://repo.cw-ngv.com/archive/$release binary/" | sudo tee --append /etc/apt/sources.list.d/clearwater.list
    fi
    curl -L http://repo.cw-ngv.com/repo_key | sudo apt-key add -
fi
sudo apt-get update

ctx logger info "Installing vellum packages and other clearwater packages"
set +e
sudo DEBIAN_FRONTEND=noninteractive  apt-get -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confnew install vellum --yes --force-yes
sudo DEBIAN_FRONTEND=noninteractive  apt-get install clearwater-management --yes --force-yes
set -e
ctx logger info "The installation packages is done correctly"

ctx logger info "Use the DNS server"
echo 'RESOLV_CONF=/etc/dnsmasq.resolv.conf' | sudo tee --append  /etc/default/dnsmasq
sudo service dnsmasq force-reload

ctx logger info "Installation is done"
