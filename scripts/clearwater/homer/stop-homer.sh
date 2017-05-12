#!/bin/bash -e

ctx logger info "Stopping homer node"

sudo monit unmonitor -g homer

# sudo service homer stop

sudo monit unmonitor clearwater_cluster_manager
sudo monit unmonitor clearwater_config_manager
sudo monit unmonitor -g etcd
