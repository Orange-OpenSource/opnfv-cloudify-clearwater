#!/bin/bash -e

ctx logger info "Starting homestead node"

sudo service homestead start
sudo service homestead-prov start
