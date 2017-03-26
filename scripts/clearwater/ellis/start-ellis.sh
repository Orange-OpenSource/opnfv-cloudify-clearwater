#!/bin/bash -e

function wait_for_service() {
  ip=$1
  port=$2

  started=false

  ctx logger info "Running liveness detection on port ${port}"

  for i in $(seq 1 24)
  do
    if [ echo >/dev/tcp/${ip}/${port} ]; then
        started=true
        break
    else
        ctx logger debug "Service on port ${port} has not started. waiting..."
        sleep 10
    fi
  done
  if [ ${started} = false ]; then
      ctx logger error "Service on port ${port} failed to start. waited for a 120 seconds."
      exit 1
  fi
}

local_ip=$(ctx instance host_ip)

ctx logger info "Starting ellis node"

sudo service ellis start

sudo monit monitor -g ellis

set +e
sudo monit monitor clearwater_cluster_manager
sudo monit monitor clearwater_config_manager
sudo monit monitor -g etcd
set -e

wait_for_service ${local_ip} 80
