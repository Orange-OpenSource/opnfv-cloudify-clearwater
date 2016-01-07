#!/bin/bash -e

ctx logger info "Stopping sprout node"

sudo monit unmonitor -g sprout

sudo timeout 180 service sprout quiesce

sudo monit unmonitor clearwater_cluster_manager
sudo monit unmonitor clearwater_config_manager
sudo monit unmonitor -g etcd