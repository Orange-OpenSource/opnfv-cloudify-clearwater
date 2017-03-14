#!/bin/bash -e

ctx logger info "Starting bono node"

sudo service bono start

sudo monit monitor -g bono

sudo monit monitor clearwater_cluster_manager
sudo monit monitor clearwater_config_manager
sudo monit monitor -g etcd
