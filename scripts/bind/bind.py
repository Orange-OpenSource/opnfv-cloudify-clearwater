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
CONFIG_PATH_NAMED = '/etc/bind/named.conf.local'
CONFIG_PATH_NAMESERVER = '/etc/dnsmasq.resolv.conf'
CONFIG_PATH_ETCD = '/etc/clearwater/shared_config'
CONFIG_PATH_LOCAL_CONF = '/etc/clearwater/local_config'

# Path of jinja template config files
TEMPLATE_RESOURCE_NAME_NAMED = 'resources/bind/named.conf.local.template'
TEMPLATE_RESOURCE_NAME_PRIVATE = 'resources/bind/private.domain.db.template'
TEMPLATE_RESOURCE_NAME_PUBLIC = 'resources/bind/public.domain.db.template'
TEMPLATE_RESOURCE_NAME_NAMESERVER = 'resources/bind/dnsmasq.template'
TEMPLATE_RESOURCE_NAME_ETCD = 'resources/clearwater/shared_config.template'
TEMPLATE_RESOURCE_NAME_LOCAL_CONF = 'resources/clearwater/local_config.template'



def configure(subject=None):
    subject = subject or ctx

    # Get bind floating IP
    relationships = subject.instance.relationships
    public_ip = ''
    for element in relationships:
        if element.type == 'cloudify.relationships.contained_in':
            for elements in element.target.instance.relationships:
                if elements.type == 'cloudify.openstack.server_connected_to_floating_ip':
                    public_ip = elements.target.instance.runtime_properties['floating_ip_address']

    ctx.logger.info('Creating private domain file')

    template = Template(ctx.get_resource(TEMPLATE_RESOURCE_NAME_PRIVATE))

    PRIVATE_DOMAIN = subject.node.properties['private_domain']
    CONFIG_PATH_PRIVATE = '/etc/bind/db.{0}'.format(PRIVATE_DOMAIN)

    ctx.logger.debug('Building a dict object that will contain variables '
                     'to write to the Jinja2 template.')

    config = subject.node.properties.copy()
    config.update(dict(
        backends=subject.instance.runtime_properties.get('backends', {}),
        host_ip=subject.instance.host_ip,
        public_ip=public_ip))

    # Generate private domain file from jinja template
    ctx.logger.debug('Rendering the Jinja2 template to {0}.'.format(CONFIG_PATH_PRIVATE))
    ctx.logger.debug('The config dict: {0}.'.format(config))

    with tempfile.NamedTemporaryFile(delete=False) as temp_config:
        temp_config.write(template.render(config))

    _run('sudo mv {0} {1}'.format(temp_config.name, CONFIG_PATH_PRIVATE),
         error_message='Failed to write to {0}.'.format(CONFIG_PATH_PRIVATE))

    _run('sudo chmod 644 {0}'.format(CONFIG_PATH_PRIVATE),
         error_message='Failed to change permissions {0}.'.format(CONFIG_PATH_PRIVATE))

    ctx.logger.info('Creating public domain file')

    PUBLIC_DOMAIN = subject.node.properties['public_domain']
    CONFIG_PATH_PUBLIC = '/etc/bind/db.{0}'.format(PUBLIC_DOMAIN)

    ctx.logger.debug('Rendering the Jinja2 template to {0}.'.format(CONFIG_PATH_PUBLIC))
    ctx.logger.debug('The config dict: {0}.'.format(config))

    template = Template(ctx.get_resource(TEMPLATE_RESOURCE_NAME_PUBLIC))
    # Generate public domain file from jinja template
    with tempfile.NamedTemporaryFile(delete=False) as temp_config:
        temp_config.write(template.render(config))

    _run('sudo mv {0} {1}'.format(temp_config.name, CONFIG_PATH_PUBLIC),
         error_message='Failed to write to {0}.'.format(CONFIG_PATH_PUBLIC))

    _run('sudo chmod 644 {0}'.format(CONFIG_PATH_PUBLIC),
         error_message='Failed to change permissions {0}.'.format(CONFIG_PATH_PUBLIC))

    # Reload bind server to reload new domain configuration
    reload()



def install(subject=None):
    subject = subject or ctx

    # Install bind server and dependancies
    ctx.logger.debug('Installing BIND DNS server')
    _run('sudo apt-get update',
        error_message='Failed to update package lists')
    _run('sudo DEBIAN_FRONTEND=noninteractive apt-get install bind9 --yes',
         error_message='Failed to install BIND packages')

    # Generate bind config files from jinja template
    template = Template(ctx.get_resource(TEMPLATE_RESOURCE_NAME_LOCAL_CONF))

    config = subject.node.properties.copy()
    config.update(dict(
        name='bind',
        host_ip=subject.instance.host_ip,
        etcd_ip=subject.instance.host_ip))

    ctx.logger.debug('Rendering the Jinja2 template to {0}.'.format(CONFIG_PATH_LOCAL_CONF))
    ctx.logger.debug('The config dict: {0}.'.format(config))

    with tempfile.NamedTemporaryFile(delete=False) as temp_config:
        temp_config.write(template.render(config))

    _run('sudo mkdir -p /etc/clearwater', error_message='Failed to create clearwater config directory.')

    _run('sudo mv {0} {1}'.format(temp_config.name, CONFIG_PATH_LOCAL_CONF),
         error_message='Failed to write to {0}.'.format(CONFIG_PATH_LOCAL_CONF))
    _run('sudo chmod 644 {0}'.format(CONFIG_PATH_LOCAL_CONF),
         error_message='Failed to change permissions {0}.'.format(CONFIG_PATH_LOCAL_CONF))

    ctx.logger.debug('Rendering the Jinja2 template to {0}.'.format(CONFIG_PATH_NAMED))
    ctx.logger.debug('The config dict: {0}.'.format(config))

    template = Template(ctx.get_resource(TEMPLATE_RESOURCE_NAME_NAMED))

    with tempfile.NamedTemporaryFile(delete=False) as temp_config:
        temp_config.write(template.render(config))

    _run('sudo mv {0} {1}'.format(temp_config.name, CONFIG_PATH_NAMED),
         error_message='Failed to write to {0}.'.format(CONFIG_PATH_NAMED))

    _run('sudo chmod 644 {0}'.format(CONFIG_PATH_NAMED),
         error_message='Failed to change permissions {0}.'.format(CONFIG_PATH_NAMED))


    # Generate shared_config file for clearwater-etcd software
    template = Template(ctx.get_resource(TEMPLATE_RESOURCE_NAME_ETCD))

    ctx.logger.debug('Rendering the Jinja2 template to {0}.'.format(CONFIG_PATH_ETCD))
    ctx.logger.debug('The config dict: {0}.'.format(config))

    with tempfile.NamedTemporaryFile(delete=False) as temp_config:
        temp_config.write(template.render(config))

    _run('sudo mv {0} {1}'.format(temp_config.name, CONFIG_PATH_ETCD),
         error_message='Failed to write to {0}.'.format(CONFIG_PATH_ETCD))
    _run('sudo chmod 644 {0}'.format(CONFIG_PATH_ETCD),
         error_message='Failed to change permissions {0}.'.format(CONFIG_PATH_ETCD))


    configure(subject=None)



# Add a new entre on the DNS domains
def add_backend(backend_address=None):
    role = name = ctx.source.instance.id
    role = re.split(r'_',role)[0]
    relationships = ctx.source.instance.relationships
    public_ip = ''
    for element in relationships:
        if element.type == 'cloudify.relationships.contained_in':
            for elements in element.target.instance.relationships:
                if elements.type == 'cloudify.openstack.server_connected_to_floating_ip':
                    public_ip = elements.target.instance.runtime_properties['floating_ip_address']

    with _backends_update() as backends:
        try:
            backends[role]
        except:
            backends[role] = {}
        backends[role][ctx.source.instance.id] = {
            'private_address': backend_address or ctx.source.instance.host_ip,
            'name': name.replace('_','-'),
            'public_address' : public_ip
        }

# remove entre on the DNS domains
def remove_backend():
    role = ctx.source.instance.id
    role = re.split(r'_',role)[0]
    with _backends_update() as backends:
        backends[role].pop(ctx.source.instance.id, None)


@contextmanager
def _backends_update():
    backends = ctx.target.instance.runtime_properties.get('backends', {})
    yield backends
    ctx.target.instance.runtime_properties['backends'] = backends
    # being explict because errors in unlink are ignored and
    # not retried without being explicit.
    # also, this way, we make sure that configure/reload
    # are only called with a fully update configuration
    try:
        ctx.target.instance.update()
        configure(subject=ctx.target)
    except rest_exceptions.CloudifyClientError as e:
        if 'conflict' in str(e):
            # cannot 'return' in contextmanager
            ctx.operation.retry(
                message='Backends updated concurrently, retrying.',
                retry_after=1)
        else:
            raise


def start():
    _service('start')


def stop():
    _service('stop')


def reload():
    _service('reload')


def _service(state):
    _run('sudo service bind9 {0}'.format(state),
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
