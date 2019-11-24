#!/bin/bash -e

log () {
    ctx logger info "[etcd] $(echo $@ |cut -d\- -f1)"
    output=$((time $@) 2>&1)
    ctx logger info "[etcd] => ${output}"
}

ctx logger info "[etcd] ${COMMAND}"

release=$(ctx node properties release)
ctx logger info "[etcd] ${release}"

ctx logger info "[etcd] Configure the APT software source"
if [ ! -f /etc/apt/sources.list.d/clearwater.list ]
  then
    echo 'deb http://artifacts.opnfv.org/functest/clearwater/debian ./' | sudo tee --append /etc/apt/sources.list.d/clearwater.list
fi
log sudo apt-get update

ctx logger info "[etcd] Now install the software"
log sudo DEBIAN_FRONTEND=noninteractive apt-get install clearwater-management --yes --force-yes
ctx logger info "[etcd] The software is installed"

log /usr/share/clearwater/clearwater-etcd/scripts/wait_for_etcd

log sudo ifconfig -a
log sudo ps -edf
log sudo netstat -lnp

log sudo pstree |true
log sudo find /var/log -type f
log sudo cat /var/log/clearwater*.log |true
log sudo cat /var/log/clearwater-cluster-manager/* |true
log sudo cat /var/log/clearwater-config-manager/* |true
log sudo cat /var/log/clearwater-etcd/* |true
log sudo cat /var/log/clearwater-queue-manager/* |true

ctx logger info "[etcd] Installation is done"
