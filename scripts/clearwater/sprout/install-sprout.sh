#!/bin/bash -e

log () {
    ctx logger info "[sprout] $(echo $@ |cut -d\- -f1)"
    output=$((time $@) 2>&1)
    ctx logger info "[sprout] => ${output}"
}

ctx logger info "[sprout] ${COMMAND}"

release=$(ctx node properties release)
ctx logger info "[sprout] ${release}"

ctx logger info "[sprout] Configure the APT software source"
if [ ! -f /etc/apt/sources.list.d/clearwater.list ]
  then
    echo 'deb http://artifacts.opnfv.org/functest/clearwater/debian ./' | sudo tee --append /etc/apt/sources.list.d/clearwater.list
fi
log sudo apt-get update

ctx logger info "[sprout] Installing ralf packages and other clearwater packages"
log sudo DEBIAN_FRONTEND=noninteractive apt-get install sprout --yes --force-yes -o DPkg::options::=--force-confnew
log sudo DEBIAN_FRONTEND=noninteractive  apt-get install clearwater-management --yes --force-yes
ctx logger info "[sprout] The installation packages is done correctly"

ctx logger info "[sprout] Use the DNS server"
echo 'RESOLV_CONF=/etc/dnsmasq.resolv.conf' | sudo tee --append  /etc/default/dnsmasq
log sudo service dnsmasq force-reload

log sudo ifconfig -a
log sudo ps -edf
log sudo netstat -lnp

log sudo find /var/log
log sudo cat /var/log/clearwater*.log |true
log sudo cat /var/log/clearwater-cluster-manager/* |true
log sudo cat /var/log/clearwater-config-manager/* |true
log sudo cat /var/log/clearwater-etcd/* |true
log sudo cat /var/log/clearwater-queue-manager/* |true

ctx logger info "[sprout] Installation is done"
