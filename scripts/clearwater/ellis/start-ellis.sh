#!/bin/bash -e

ctx logger info "Starting ellis node"

sudo service ellis start

sudo monit monitor -g ellis

sudo monit monitor clearwater_cluster_manager
sudo monit monitor clearwater_config_manager
sudo monit monitor -g etcd
