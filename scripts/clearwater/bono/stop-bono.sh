#!/bin/bash -e

ctx logger info "Stopping bono node"

sudo monit unmonitor -g bono

sudo timeout 180 service bono quiesce

sudo monit unmonitor -g clearwater_cluster_manager
sudo monit unmonitor -g clearwater_config_manager
sudo monit unmonitor -g clearwater_queue_manager
sudo monit unmonitor -g etcd
sudo service clearwater-etcd decommission
