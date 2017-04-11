from cloudify import ctx
from cloudify import exceptions
import diamond_agent.tasks as diamond

import os
workdir = ctx.plugin.workdir
paths = diamond.get_paths(workdir.replace("script","diamond"))
name = 'SNMPProxyCollector'

collector_dir = os.path.join(paths['collectors'], name)
if not os.path.exists(collector_dir):
    os.mkdir(collector_dir)
    collector_file = os.path.join(collector_dir, '{0}.py'.format(name))
    ctx.download_resource('scripts/monitoring/proxy_snmp/snmpproxy.py', collector_file)

config = ctx.target.instance.runtime_properties.get('snmp_collector_config', {})
config.update({'enabled': True,
                   'hostname': '{0}.{1}.{2}'.format(diamond.get_host_id(ctx.target),
                                                    ctx.target.node.name,
                                                    ctx.target.instance.id)
                   })

config_full_path = os.path.join(paths['collectors_config'], '{0}.conf'.format(name))
diamond.write_config(config_full_path, config)

try:
	diamond.stop_diamond(paths['config'])
except:
	pass

try:
	diamond.start_diamond(paths['config'])
except:
	exceptions.RecoverableError("Failed to start diamond", 30)
pass
