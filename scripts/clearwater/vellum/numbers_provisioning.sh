#!/bin/bash -e

ctx logger debug "${COMMAND}"


public_domain=$(ctx node properties public_domain)
end_number=$(ctx node properties end_number)

if [ ! -d "/usr/share/clearwater/crest/tools/sstable_provisioning/homestead_cache" ]; then
  cd /usr/share/clearwater/crest/tools/sstable_provisioning/

  sudo ./BulkProvision homestead-local 2010000000 $end_number $public_domain toto
  sudo ./BulkProvision homestead-hss 2010000000 $end_number $public_domain toto
  sudo ./BulkProvision homer 2010000000 $end_number $public_domain toto

  . /etc/clearwater/config
  sstableloader -v -d ${cassandra_hostname:-$local_ip} homer/simservs
  sstableloader -v -d ${cassandra_hostname:-$local_ip} homestead_cache/impi
  sstableloader -v -d ${cassandra_hostname:-$local_ip} homestead_cache/impu
  sstableloader -v -d ${cassandra_hostname:-$local_ip} homestead_provisioning/implicit_registration_sets
  sstableloader -v -d ${cassandra_hostname:-$local_ip} homestead_provisioning/public
  sstableloader -v -d ${cassandra_hostname:-$local_ip} homestead_provisioning/private
  sstableloader -v -d ${cassandra_hostname:-$local_ip} homestead_provisioning/service_profiles
fi
