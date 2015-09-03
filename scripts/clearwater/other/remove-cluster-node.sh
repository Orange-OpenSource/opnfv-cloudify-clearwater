#!/bin/bash 

ctx logger info "Remove node in ETCD cluster"

sudo service clearwater-etcd decommission

