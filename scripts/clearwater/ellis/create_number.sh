#!/bin/bash -e

ctx logger debug "${COMMAND}"

ctx logger info "Start numbers creation"
while [ ! -f /etc/clearwater/shared_config ]
do
  sleep 10
done
ctx logger info "$(cat /etc/clearwater/shared_config)"
sudo service clearwater-infrastructure restart
sudo service ellis stop
sudo /usr/share/clearwater/ellis/env/bin/python /usr/share/clearwater/ellis/src/metaswitch/ellis/tools/create_numbers.py --start 6505550000 --count 1000
