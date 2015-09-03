#######################################################################
# coding: utf8
#
#   Copyright (c) 2015 Orange
#   valentin.boucher@orange.com
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
########################################################################

import os
import subprocess
import tempfile
import re
from contextlib import contextmanager

from jinja2 import Template

from cloudify_rest_client import exceptions as rest_exceptions
from cloudify import ctx
from cloudify.state import ctx_parameters as inputs
from cloudify import exceptions
from cloudify import utils

# -*- coding: utf-8 -*-

# config files destination
CONFIG_PATH = '/etc/clearwater/local_config'
CONFIG_PATH_NAMESERVER = '/etc/dnsmasq.resolv.conf'

# Path of jinja template config files
TEMPLATE_RESOURCE_NAME = 'resources/clearwater/local_config.template'
TEMPLATE_RESOURCE_NAME_NAMESERVER = 'resources/bind/dnsmasq.template'


def configure(subject=None):
    subject = subject or ctx

    ctx.logger.info('Configuring clearwater node.')
    template = Template(ctx.get_resource(TEMPLATE_RESOURCE_NAME))

    ctx.logger.debug('Building a dict object that will contain variables '
                     'to write to the Jinja2 template.')

    # Get the host public IP
    name = ctx.instance.id
    relationships = ctx.instance.relationships
    public_ip = ''
    for element in relationships:
        if element.type == 'cloudify.relationships.contained_in':
            for elements in element.target.instance.relationships:
                if elements.type == 'cloudify.openstack.server_connected_to_floating_ip':
                    public_ip = elements.target.instance.runtime_properties['floating_ip_address']

    # Get bind host IP
    binds = []
    for element in relationships:
        text = element.target.instance.id
        if re.split(r'_',text)[0] == 'bind':
            binds.append(element.target.instance.host_ip)

    config = subject.node.properties.copy()
    config.update(dict(
        name=name.replace('_','-'),
        host_ip=subject.instance.host_ip,
        etcd_ip=binds[0],
        public_ip=public_ip))


    ctx.logger.debug('Rendering the Jinja2 template to {0}.'.format(CONFIG_PATH))
    ctx.logger.debug('The config dict: {0}.'.format(config))

    # Generate local_config file from jinja template
    with tempfile.NamedTemporaryFile(delete=False) as temp_config:
        temp_config.write(template.render(config))

    _run('sudo mkdir -p /etc/clearwater', error_message='Failed to create clearwater config directory.')

    _run('sudo mv {0} {1}'.format(temp_config.name, CONFIG_PATH),
         error_message='Failed to write to {0}.'.format(CONFIG_PATH))
    _run('sudo chmod 644 {0}'.format(CONFIG_PATH),
         error_message='Failed to change permissions {0}.'.format(CONFIG_PATH))

    template = Template(ctx.get_resource(TEMPLATE_RESOURCE_NAME_NAMESERVER))

    config = subject.node.properties.copy()

    config.update(dict(binds=binds))

    # Generate dnsmasq file from jinja template
    with tempfile.NamedTemporaryFile(delete=False) as temp_config:
        temp_config.write(template.render(config))

    _run('sudo mv {0} {1}'.format(temp_config.name, CONFIG_PATH_NAMESERVER),
         error_message='Failed to write to {0}.'.format(CONFIG_PATH_NAMESERVER))

    _run('sudo chmod 644 {0}'.format(CONFIG_PATH_NAMESERVER),
         error_message='Failed to change permissions {0}.'.format(CONFIG_PATH_NAMESERVER))


def start():
    _service('start')


def stop():
    _service('stop')


def _service(state):
    role = re.split(r'_',ctx.instance.id)[0]
    _run('sudo service {0} {1}'.format(role,state),
         error_message='Failed setting state to {0}'.format(state))


def _run(command, error_message):
    runner = utils.LocalCommandRunner(logger=ctx.logger)
    try:
        runner.run(command)
    except exceptions.CommandExecutionException as e:
        raise exceptions.NonRecoverableError('{0}: {1}'.format(error_message, e))


def _main():
    invocation = inputs['invocation']
    function = invocation['function']
    args = invocation.get('args', [])
    kwargs = invocation.get('kwargs', {})
    globals()[function](*args, **kwargs)


if __name__ == '__main__':
    _main()