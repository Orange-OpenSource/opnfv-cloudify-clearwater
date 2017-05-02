#!/bin/bash -e

ctx logger info "Stopping homestead node"

sudo monit unmonitor -g homestead
sudo monit unmonitor -g homestead-prov

sudo service homestead stop && sudo service homestead-prov stop

sudo monit unmonitor clearwater_cluster_manager
sudo monit unmonitor clearwater_config_manager
sudo monit unmonitor -g etcd
