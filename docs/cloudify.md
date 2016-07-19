# Cloudify
## Introduction

[See](http://getcloudify.org/cloud_orchestration_cloud_automation.html) more about Cloudify orchestrator !

## Install

### Cloudify CLI

Cloudify CLI allow to create cloudify-manager-server on OpenStack cloud platform

To install Cloudify CLI you have two choice :
* Follow cloudify [documentation](http://getcloudify.org/guide/3.2/installation.html) to install Cloudify CLI on Windows, Linux or OSX and after read the next part (Cloudify manager deployment);
* Provide cloudify CLI VM on OpenStack platform;



Create cloudify-cli VM :
* Ubuntu **14.04**


Log into this VM and after, install python packages :
```
sudo apt-get update
sudo apt-get install git python-pip python-dev python-virtualenv -y
```

Create virtual environment :
```
virtualenv cloudify
source cloudify/bin/activate
cd cloudify
```
Install cloudify CLI version 3.2 with the PIP command : 
```
pip install cloudify==3.4
```

Test if the command cfy exists 
```
cfy
```
If this result appears on console, follow the next part (Deploy cloudify management server)
```
usage: cfy [-h] [--version]
           {status,use,executions,ssh,workflows,recover,blueprints,teardown,bootstrap,dev,deployments,init,local,events}
           ...
cfy: error: too few arguments
```


### Deploy cloudify management server :

For more explanation, [see](http://getcloudify.org/guide/3./getting-started-bootstrapping.html) the cloudify bootstrap documentation !

Log into the host where you installed the **Cloudify CLI** and enter in the virtual environment with source command.

Prepare your directory :
```
mkdir -p cloudify-manager
cd cloudify-manager
```

Download manager blueprint version 3.4 :
```
git clone -b 3.4-build https://github.com/cloudify-cosmo/cloudify-manager-blueprints.git
```

Prepare deployment on OpenStack platform :
```
cfy init
cd cloudify-manager-blueprints/
```
Install required packages for deployment :
```
cfy local create-requirements -o requirements.txt -p openstack-manager-blueprint.yaml
sudo pip install -r requirements.txt
```

The configuration for the cloudify manager deployment is contained in a YAML file. 
A template configuration file exist, you can edit it with the desired values.
```
vi openstack-manager-blueprint-inputs.yaml
```

Bellow an example of inputs.yaml file configurations for [CloudWatt](https://www.cloudwatt.com/en/) platform. CloudWatt is a public OpenStack cloud made in France. You can help with this example to generate your configuration file for your OpenStack platform.
```
vi inputs.yaml
```
```yaml
keystone_username: 'your_openstack_username'
keystone_password: 'your_openstack_password'
keystone_tenant_name: 'your_openstack_tenant'
keystone_url: 'https://identity.fr1.cloudwatt.com/v2.0'
region: 'fr1'											# OpenStack region : look openrc file
manager_public_key_name: 'manager-kp'
agent_public_key_name: 'agent-kp'
image_id: '9209c396-58bd-4305-9f1d-d9a636cc2da2'		# OS image ID (CentOS 7)
flavor_id: '18'											# Flavor ID (~ 4 Go RAM)
external_network_name: public 							# external network on Openstack


ssh_user: 'cloud' 										# SSH user used to connect to the manager
agents_user: 'cloud' 									# SSH user used to connect to agent VM
```

Launch the deployment of cloudify manager server : 
```
 cfy bootstrap --install-plugins -p openstack-manager-blueprint.yaml -i openstack-manager-blueprint-inputs.yaml
```

During the deployment many **logs** appears on console :
```
2015-08-31 14:57:15 CFY <manager> [agents_security_group_d4d74.create] Task succeeded 'neutron_plugin.security_group.create'
2015-08-31 14:57:15 CFY <manager> [agent_keypair_a8933] Configuring node
2015-08-31 14:57:15 CFY <manager> [router_c3be5] Configuring node
```
Check the proper functioning of the server :
```
cfy status
```
If this result appears on console, your cloudify manager is installed  and operating
```
Getting management services status... [ip=84.**.**.**]

Services:
+--------------------------------+--------+
|            service             | status |
+--------------------------------+--------+
| Riemann                        |   up   |
| Celery Management              |   up   |
| Manager Rest-Service           |   up   |
| AMQP InfluxDB                  |   up   |
| RabbitMQ                       |   up   |
| Elasticsearch                  |   up   |
| Webserver                      |   up   |
| Logstash                       |   up   |
+--------------------------------+--------+
```

After, you can deploy clearwater ! See this [documentation](clearwater.md)

## Uninstall

Before uninstall cloudify-manager, you must have uninstall and delete **all deployments** !

Log into the host where you installed the **Cloudify CLI** and enter in the virtual environment with source command.

To uninstall properly cloudify-manager, execute this command :
```
cfy teardown -f 
```
