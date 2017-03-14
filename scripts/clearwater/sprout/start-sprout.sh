#!/bin/bash -e

ctx logger info "Starting sprout node"

sudo service sprout start

sudo monit monitor -g sprout

sudo monit monitor clearwater_cluster_manager
sudo monit monitor clearwater_config_manager
sudo monit monitor -g etcd
