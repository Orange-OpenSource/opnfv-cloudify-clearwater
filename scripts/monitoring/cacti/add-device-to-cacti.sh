#!/bin/bash

ctx logger debug "${COMMAND}"

ip=$(ctx source instance host_ip)
name=$(ctx source instance id)
tmpl_name=(${name//_/ })

case $tmpl_name in
	sprout)
		tmpl_name=Sprout
		;;
	bono)
		tmpl_name=Bono
		;;
	sipp)
		tmpl_name=SIPp
		;;
esac

cd /usr/share/cacti/cli

# Get the template number from the name
tmpl=`sudo ./add_device.php --list-host-templates | grep $tmpl_name | cut -f1`

# Add the host, associating it with the appropriate template
sudo ./add_device.php --ip=$ip --description=$name --community=clearwater --template=$tmpl --avail=snmp

# Find the ID of this host
this_node=`sudo ./add_graphs.php --list-hosts | grep $name | cut -f1`

# Add an entry for this host to the graphs tree
sudo ./add_tree.php --type=node --node-type=host --host-id=$this_node --tree-id=1

# Add each graph for the host
for graph in `sudo ./add_graphs.php --list-graph-templates --host-template-id=$tmpl | grep -E "^[0-9]" |
  cut -f 1`
do
  sudo ./add_graphs.php --host-id=$this_node --graph-type=cg --graph-template-id=$graph
done