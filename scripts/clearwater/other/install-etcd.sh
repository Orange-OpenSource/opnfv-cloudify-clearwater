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
    if [ $release = "stable" ]
    then
      echo 'deb http://repo.cw-ngv.com/stable binary/' | sudo tee --append /etc/apt/sources.list.d/clearwater.list
    else
      echo "deb http://repo.cw-ngv.com/archive/$release binary/" | sudo tee --append /etc/apt/sources.list.d/clearwater.list
    fi
    curl -L http://repo.cw-ngv.com/repo_key | sudo apt-key add -
fi
log sudo apt-get update

ctx logger info "[etcd] Now install the software"
log sudo DEBIAN_FRONTEND=noninteractive apt-get install clearwater-management --yes --force-yes
ctx logger info "[etcd] The software is installed"

log /usr/share/clearwater/clearwater-etcd/scripts/wait_for_etcd
log sudo /usr/share/clearwater/clearwater-config-manager/scripts/upload_shared_config
# sudo /usr/share/clearwater/clearwater-config-manager/scripts/apply_shared_config

ctx logger info "[etcd] Installation is done"
