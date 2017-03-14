#!/bin/bash -e

ctx logger info "Starting homer node"

sudo service homer start

sudo monit monitor -g homer

sudo monit monitor clearwater_cluster_manager
sudo monit monitor clearwater_config_manager
sudo monit monitor -g etcd
