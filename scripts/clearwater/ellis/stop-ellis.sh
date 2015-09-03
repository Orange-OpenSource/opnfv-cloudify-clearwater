#!/bin/bash -e

ctx logger info "Stopping ellis node"

sudo monit unmonitor -g ellis

sudo service ellis stop

sudo monit unmonitor clearwater_cluster_manager
sudo monit unmonitor clearwater_config_manager
sudo monit unmonitor -g etcd