#!/bin/bash -e

ctx logger info "Stopping vellum node"

sudo monit unmonitor -g vellum

sudo service vellum stop 

sudo monit unmonitor clearwater_cluster_manager
sudo monit unmonitor clearwater_config_manager
sudo monit unmonitor -g etcd
