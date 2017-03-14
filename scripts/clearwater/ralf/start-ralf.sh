#!/bin/bash -e

ctx logger info "Starting ralf node"

sudo service ralf start

sudo monit monitor -g ralf

sudo monit monitor clearwater_cluster_manager
sudo monit monitor clearwater_config_manager
sudo monit monitor -g etcd
