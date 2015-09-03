# coding=utf-8

import time

from snmpraw import SNMPRawCollector
from diamond.metric import Metric


class SNMPProxyCollector(SNMPRawCollector):

    def collect_snmp(self, device, host, port, community):
        """
        Collect SNMP interface data from device
        """
        self.log.debug(
            'Collecting raw SNMP statistics from device \'{0}\''.format(device)
        )

        try:
            self.skip_time
        except:
            self.skip_time = time.time()

        time_diff = time.time() - self.skip_time
        if (time_diff) > 30:
            self.skip_list[:] = []
            self.skip_time = time.time()

        dev_config = self.config['devices'][device]
        if 'oids' in dev_config:
            for oid, metricName in dev_config['oids'].items():

                if (device, oid) in self.skip_list:
                    self.log.debug(
                        'Skipping OID \'{0}\' ({1}) on device \'{2}\''.format(
                            oid, metricName, device))
                    continue

                timestamp = time.time()
                value = self._get_value(device, oid, host, port, community)
                if value is None:
                    continue

                self.log.debug(
                    '\'{0}\' ({1}) on device \'{2}\' - value=[{3}]'.format(
                        oid, metricName, device, value))

                device_path = '{}.{}.{}'.format(
                    dev_config['node_id'],
                    device,
                    dev_config['node_instance_id']
                )
                path = '.'.join([self.config['path_prefix'], device_path,
                                 self.config['path_suffix'], metricName])
                metric = Metric(path=path, value=value, timestamp=timestamp,
                                precision=self._precision(value),
                                host=device_path, metric_type='GAUGE')
                self.publish_metric(metric)
