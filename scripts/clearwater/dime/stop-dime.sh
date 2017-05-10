#!/bin/bash -e

ctx logger info "Stopping dime node"

sudo monit unmonitor -g dime

sudo service dime stop

sudo monit unmonitor clearwater_cluster_manager
sudo monit unmonitor clearwater_config_manager
sudo monit unmonitor -g etcd
