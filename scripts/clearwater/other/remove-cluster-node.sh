#!/bin/bash 

ctx logger info "Remove node in ETCD cluster"

sudo timeout 180 service clearwater-etcd decommission

