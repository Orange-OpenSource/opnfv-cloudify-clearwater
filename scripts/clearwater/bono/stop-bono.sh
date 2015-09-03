#!/bin/bash -e

ctx logger info "Stopping bono node"

sudo monit unmonitor -g bono

sudo service bono quiesce

sudo monit unmonitor clearwater_config_manager
sudo monit unmonitor -g etcd