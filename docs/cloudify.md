# Cloudify
## Introduction

[See](http://cloudify.co/product/) more about Cloudify orchestrator !

## Install

### Cloudify Manager

Before starting, requierements:
* One security group with port tcp/22, tcp/80, tcp/443 open
* One network with internet access (subnet, network and router)

Download cloudify-manager image:
```
wget http://repository.cloudifysource.org/cloudify/4.0.1/sp-release/cloudify-manager-premium-4.0.1.qcow2
```
Upload this image on your OpenStack platform


Create one VM with this image and a flavor with 4 Gb of memory

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
