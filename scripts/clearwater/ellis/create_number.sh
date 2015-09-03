#!/bin/bash -e

ctx logger debug "${COMMAND}"

ctx logger info "Start numbers creation"
while [ ! -f /etc/clearwater/shared_config ]
do
  sleep 10
done
sudo bash -c "export PATH=/usr/share/clearwater/ellis/env/bin:$PATH ;
              cd /usr/share/clearwater/ellis/src/metaswitch/ellis/tools/ ;
              python create_numbers.py --start 6505550000 --count 1000"
