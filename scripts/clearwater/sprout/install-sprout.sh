!/bin/bash -e

ctx logger debug "${COMMAND}"

sudo mkdir -p /etc/chronos

echo '
[http]
bind-address = 10.0.0.4
bind-port = 7253
threads = 50
[logging]
folder = /var/log/chronos
level = 2
[alarms]
enabled = true
[exceptions]
max_ttl = 600' | sudo tee --append /etc/chronos/chronos.conf

ctx logger info "Configure the APT software source"
if [ ! -f /etc/apt/sources.list.d/clearwater.list ]
  then
    echo 'deb http://repo.cw-ngv.com/stable binary/' | sudo tee --append /etc/apt/sources.list.d/clearwater.list
    curl -L http://repo.cw-ngv.com/repo_key | sudo apt-key add -
fi
sudo apt-get update

ctx logger info "Installing ralf packages and other clearwater packages"
sudo DEBIAN_FRONTEND=noninteractive apt-get install sprout --yes --force-yes -o DPkg::options::=--force-confnew
sudo DEBIAN_FRONTEND=noninteractive  apt-get install clearwater-management --yes --force-yes
ctx logger info "The installation packages is done correctly"


echo '
log_level=5

authentication='Y''| sudo tee --append /etc/clearwater/user_settings


ctx logger info "Use the DNS server"
echo 'RESOLV_CONF=/etc/dnsmasq.resolv.conf' | sudo tee --append  /etc/default/dnsmasq
sudo service dnsmasq force-reload

ctx logger info "Installation is done"
echo "END "
