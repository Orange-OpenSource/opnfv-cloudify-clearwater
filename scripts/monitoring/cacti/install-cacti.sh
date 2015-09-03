#!/bin/bash -e 

ctx logger debug "${COMMAND}"

ctx logger info "Install cacti"

sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install git cacti cacti-spine --yes --force-yes

sudo apt-get install -y --force-yes git ruby1.9.3 build-essential libzmq3-dev
sudo gem install bundler --no-ri --no-rdoc
sudo git clone https://github.com/Metaswitch/cpp-common.git
cd cpp-common/scripts/stats
sudo bundle install

sudo mkdir -p /usr/share/clearwater/cacti/templates
sudo chmod 777 -R /usr/share/clearwater/cacti/

cd /usr/share/clearwater/cacti
wget https://raw.githubusercontent.com/Metaswitch/chef/master/cookbooks/clearwater/files/default/cacti/cactidb.sql
mysql -u root cacti < cactidb.sql

cd templates
wget https://raw.githubusercontent.com/Metaswitch/chef/master/cookbooks/clearwater/files/default/cacti/templates/cacti_host_template_sprout.xml
wget https://raw.githubusercontent.com/Metaswitch/chef/master/cookbooks/clearwater/files/default/cacti/templates/cacti_host_template_sipp.xml
wget https://raw.githubusercontent.com/Metaswitch/chef/master/cookbooks/clearwater/files/default/cacti/templates/cacti_host_template_bono.xml

cd /usr/share/cacti/cli
sudo find /usr/share/clearwater/cacti/templates -type f -exec php ./import_template.php --filename={} --with-template-rras \;
