#!/bin/bash -e

log () {
    ctx logger info "[bono] $(echo $@ |cut -d\- -f1)"
    output=$((time $@) 2>&1)
    ctx logger info "[bono] => ${output}"
}

ctx logger info "[bono] ${COMMAND}"

release=$(ctx node properties release)
ctx logger info "[bono] ${release}"

ctx logger info "[bono] Configure the APT software source"
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

ctx logger info "[bono] Installing bono packages and other clearwater packages"
log sudo DEBIAN_FRONTEND=noninteractive apt-get install bono restund --yes --force-yes -o DPkg::options::=--force-confnew
log sudo DEBIAN_FRONTEND=noninteractive apt-get install clearwater-management --yes --force-yes
log sudo DEBIAN_FRONTEND=noninteractive apt-get install clearwater-snmpd --yes --force-yes
ctx logger info "[bono] The installation packages is done correctly"

ctx logger info "[bono] Configure a new DNS server"
echo 'RESOLV_CONF=/etc/dnsmasq.resolv.conf' | sudo tee --append  /etc/default/dnsmasq
log sudo service dnsmasq force-reload

log sudo find /var/log

ctx logger info "[bono] Installation is done"
