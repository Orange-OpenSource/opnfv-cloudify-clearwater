#!/bin/bash -e

log () {
    ctx logger info "[vellum] $(echo $@ |cut -d\- -f1)"
    output=$((time $@) 2>&1)
    ctx logger info "[vellum] => ${output}"
}

ctx logger info "[vellum] ${COMMAND}"


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
ctx logger info "[vellum] ${COMMAND}"

ctx logger info "[vellum] Configure the APT software source"
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
log sudo apt-get update

ctx logger info "[vellum] Installing vellum packages and other clearwater packages"
set +e
log sudo DEBIAN_FRONTEND=noninteractive  apt-get -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confnew install vellum --yes --force-yes
log sudo DEBIAN_FRONTEND=noninteractive  apt-get install clearwater-management --yes --force-yes
set -e
ctx logger info "[vellum] The installation packages is done correctly"

ctx logger info "[vellum] Use the DNS server"
echo 'RESOLV_CONF=/etc/dnsmasq.resolv.conf' | sudo tee --append  /etc/default/dnsmasq
log sudo service dnsmasq force-reload

ctx logger info "[vellum] Installation is done"
