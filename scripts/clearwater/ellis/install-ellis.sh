#!/bin/bash -e

log () {
    ctx logger info "[ellis] $(echo $@ |cut -d\- -f1)"
    output=$((time $@) 2>&1)
    ctx logger info "[ellis] => ${output}"
}

ctx logger info "[ellis] ${COMMAND}"

release=$(ctx node properties release)
ctx logger info "[ellis] ${release}"

ctx logger info "[ellis] Configure the APT software source"
if [ ! -f /etc/apt/sources.list.d/clearwater.list ]
  then
    echo 'deb http://artifacts.opnfv.org/functest/clearwater/debian ./' | sudo tee --append /etc/apt/sources.list.d/clearwater.list
fi
log sudo apt-get update

ctx logger info "[ellis] Installing ellis packages and other clearwater packages"
log sudo  DEBIAN_FRONTEND=noninteractive apt-get install ellis --yes --force-yes -o DPkg::options::=--force-confnew
log sudo DEBIAN_FRONTEND=noninteractive apt-get install clearwater-management --yes --force-yes
ctx logger info "[ellis] The installation packages is done correctly"

ctx logger info "[ellis] Configure a new DNS server"
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

ctx logger info "[ellis] Installation is done"
