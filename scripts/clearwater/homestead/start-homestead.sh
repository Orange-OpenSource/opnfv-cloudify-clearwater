#!/bin/bash -e

ctx logger info "Starting homestead node"

sudo service homestead start
sudo service homestead-prov start

sudo monit monitor -g homestead
sudo monit monitor -g homestead-prov

sudo monit monitor clearwater_cluster_manager
sudo monit monitor clearwater_config_manager
sudo monit monitor -g etcd
