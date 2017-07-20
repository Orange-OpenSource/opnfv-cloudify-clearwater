#!/bin/bash

ctx logger debug "${COMMAND}"


start_number=2010000000
end_number=$(($start_number + $number_of_subscribers))

while [ ! -f /etc/clearwater/shared_config ]
do
  sleep 10
done

if [ ! -d "/usr/share/clearwater/crest/tools/sstable_provisioning/homestead_cache" ]; then
  cd /usr/share/clearwater/crest/tools/sstable_provisioning/

  sudo ./BulkProvision homestead-local $start_number $end_number $public_domain toto
  sudo ./BulkProvision homestead-hss $start_number $end_number $public_domain toto
  sudo ./BulkProvision homer $start_number $end_number $public_domain toto

  . /etc/clearwater/config
  sstableloader -v -d ${cassandra_hostname:-$local_ip} homer/simservs
  sstableloader -v -d ${cassandra_hostname:-$local_ip} homestead_cache/impi
  sstableloader -v -d ${cassandra_hostname:-$local_ip} homestead_cache/impu
  sstableloader -v -d ${cassandra_hostname:-$local_ip} homestead_provisioning/implicit_registration_sets
  sstableloader -v -d ${cassandra_hostname:-$local_ip} homestead_provisioning/public
  sstableloader -v -d ${cassandra_hostname:-$local_ip} homestead_provisioning/private
  sstableloader -v -d ${cassandra_hostname:-$local_ip} homestead_provisioning/service_profiles
fi
