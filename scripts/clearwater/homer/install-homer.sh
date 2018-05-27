#!/bin/bash -e

log () {
    ctx logger info "[homer] $(echo $@ |cut -d\- -f1)"
    output=$((time $@) 2>&1)
    ctx logger info "[homer] => ${output}"
}

ctx logger info "[homer] ${COMMAND}"

release=$(ctx node properties release)
ctx logger info "[homer] ${release}"

ctx logger info "[homer] Configure the APT software source"
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

ctx logger info "[homer] Installing homer packages and other clearwater packages"
set +e
log sudo DEBIAN_FRONTEND=noninteractive  apt-get -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confnew install homer --yes --force-yes
log sudo DEBIAN_FRONTEND=noninteractive  apt-get install clearwater-management --yes --force-yes
set -e
ctx logger info "[homer] The installation packages is done correctly"

ctx logger info "[homer Use the DNS server"
echo 'RESOLV_CONF=/etc/dnsmasq.resolv.conf' | sudo tee --append  /etc/default/dnsmasq
log sudo service dnsmasq force-reload

log sudo find /var/log

ctx logger info "[homer] Installation is done"
