!/bin/bash -e 

ctx logger debug "${COMMAND}"

ctx logger info "Configure the APT software source"
if [ ! -f /etc/apt/sources.list.d/clearwater.list ]
  then
    echo 'deb http://repo.cw-ngv.com/stable binary/' | sudo tee --append /etc/apt/sources.list.d/clearwater.list
    curl -L http://repo.cw-ngv.com/repo_key | sudo apt-key add -
fi
sudo apt-get update

ctx logger info "Installing bono packages and other clearwater packages"
sudo DEBIAN_FRONTEND=noninteractive apt-get install bono restund --yes --force-yes -o DPkg::options::=--force-confnew
sudo DEBIAN_FRONTEND=noninteractive apt-get install clearwater-management --yes --force-yes
sudo DEBIAN_FRONTEND=noninteractive apt-get install clearwater-snmpd --yes --force-yes
ctx logger info "The installation packages is done correctly"


IPECHO_IP=$(dig ipecho.net @8.8.8.8 | egrep '^ipecho.net.' |cut -dA -f2 |perl -pe 's/\s//g')
echo "$IPECHO_IP ipecho.net" >> /etc/hosts
echo "\n" | sudo tee --append /etc/clearwater/local_config
echo public_hostname=`wget http://ipecho.net/plain -O - -q ;`         | sudo tee --append /etc/clearwater/local_config


ctx logger info "Configure a new DNS server"
echo 'RESOLV_CONF=/etc/dnsmasq.resolv.conf' | sudo tee --append  /etc/default/dnsmasq
sudo service dnsmasq force-reload
ctx logger info "Installation is done"
echo " End"

