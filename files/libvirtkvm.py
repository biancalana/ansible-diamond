# coding=utf-8

"""
Uses libvirt to harvest per KVM instance stats

#### Dependencies

 * python-libvirt, xml

"""

import diamond.collector
from diamond.collector import str_to_bool

from string import Template

try:
    from xml.etree import ElementTree
except ImportError:
    import cElementTree as ElementTree

try:
    import libvirt
except ImportError:
    libvirt = None

import re

class LibvirtKVMCollector(diamond.collector.Collector):
    domStates = {
        libvirt.VIR_DOMAIN_NOSTATE: "nostate",
        libvirt.VIR_DOMAIN_RUNNING: "running",
        libvirt.VIR_DOMAIN_BLOCKED: "blocked",
        libvirt.VIR_DOMAIN_PAUSED: "paused",
        libvirt.VIR_DOMAIN_SHUTDOWN: "shutdown",
        libvirt.VIR_DOMAIN_SHUTOFF: "shutoff",
        libvirt.VIR_DOMAIN_CRASHED: "crashed",
        getattr(libvirt, "VIR_DOMAIN_PMSUSPENDED", 7): "pmsuspended"
    }

    blockStats = {
        'read_reqs':   0,
        'read_bytes':  1,
        'write_reqs':  2,
        'write_bytes': 3
    }

    vifStats = {
        'rx_bytes':   0,
        'rx_packets': 1,
        'rx_errors':  2,
        'rx_drops':   3,
        'tx_bytes':   4,
        'tx_packets': 5,
        'tx_errors':  6,
        'tx_drops':   7
    }

    def format_name_using_metadata(self, dom, format):
        s = Template(format)

        tree = ElementTree.fromstring(
          dom.metadata(2,
                       "http://openstack.org/xmlns/libvirt/nova/1.0"))

        for target in tree.findall('name'):
            instance = target.text

        instance_uuid = dom.UUIDString()

        for target in tree.findall('owner/project'):
            owner_project_uuid = target.get("uuid")
            owner_project = target.text

        for target in tree.findall('owner/user'):
            owner_user_uuid = target.get("uuid")
            owner_user = target.text

        instance = instance.replace(".", "_")
        owner_project = owner_project.replace(".", "_")
        owner_user = owner_user.replace(".", "_")

        params = {'owner_project':      owner_project,
                  'owner_project_uuid': owner_project_uuid,
                  'owner_user':         owner_user,
                  'owner_user_uuid':    owner_user_uuid,
                  'instance':           instance,
                  'instance_uuid':      instance_uuid}

        try:
            # remove invalid chars for Graphite
            path = re.sub(r'\s+', '_', s.substitute(params))
            return re.sub(r'[\(\)\[\]\*]+', '', path)

        except KeyError as err:
            self.log.error('invalid format parameter %s' % err)
            return instance

    def get_default_config_help(self):
        config_help = super(LibvirtKVMCollector,
                            self).get_default_config_help()
        config_help.update({
            'uri': """The libvirt connection URI. By default it's
'qemu:///system'. One decent option is
'qemu+unix:///system?socket=/var/run/libvirt/libvit-sock-ro'.""",
            'sort_by_uuid': """Use the <uuid> of the instance instead of the
 default <name>, useful in Openstack deploments where <name> is only
specific to the compute node""",
            'cpu_absolute': """CPU stats reported as percentage by default, or
as cummulative nanoseconds since VM creation if this is True."""
        })
        return config_help

    def get_default_config(self):
        """
        Returns the default collector settings
        """
        config = super(LibvirtKVMCollector, self).get_default_config()
        config.update({
            'path':     'libvirt-kvm',
            'sort_by_uuid': False,
            'uri':      'qemu:///system',
            'cpu_absolute': False
        })
        return config

    def get_devices(self, dom, type):
        devices = []

        # Create a XML tree from the domain XML description.
        tree = ElementTree.fromstring(dom.XMLDesc(0))

        for target in tree.findall("devices/%s/target" % type):
            dev = target.get("dev")
            if dev not in devices:
                devices.append(dev)

        return devices

    def get_disk_devices(self, dom):
        return self.get_devices(dom, 'disk')

    def get_dom_state(self, dom):
        return self.domStates.get(dom.state()[0], libvirt.VIR_DOMAIN_NOSTATE)

    def get_network_devices(self, dom):
        return self.get_devices(dom, 'interface')

    def report_cpu_metric(self, statname, value, instance):
        # Value in cummulative nanoseconds
        if str_to_bool(self.config['cpu_absolute']):
            metric = value
        else:
            # Nanoseconds (10^9), however, we want to express in 100%
            metric = self.derivative(statname, float(value) / 10000000.0,
                                     max_value=diamond.collector.MAX_COUNTER,
                                     instance=instance)
        self.publish(statname, metric, instance=instance)

    def collect(self):
        if libvirt is None:
            self.log.error('Unable to import libvirt')
            return {}

        self.log.debug('Connecting to %s' % self.config['uri'])

        conn = libvirt.openReadOnly(self.config['uri'])

        if conn is None:
            self.log.error('Failed to open connection to the hypervisor on %s' %
                           self.config['uri'])
            return {}

        host_dom_states = {}
        host_vcpus_provisioned = 0

        for dom in [conn.lookupByID(n) for n in conn.listDomainsID()]:
            if str_to_bool(self.config['sort_by_uuid']):
                name = dom.UUIDString()

            elif self.config['format_name_using_metadata']:
                name = self.format_name_using_metadata(
                  dom,
                  self.config['format_name_using_metadata'])

            else:
                name = dom.name()

            # VM by state
            if self.config['count_vms_by_state']:
                dom_state = self.get_dom_state(dom)
                try:
                    host_dom_states[dom_state] += 1

                except KeyError:
                    host_dom_states[dom_state] = 1

            # CPU stats
            vcpus = dom.getCPUStats(True, 0)
            totalcpu = 0
            idx = 0
            for vcpu in vcpus:
                cputime = vcpu['cpu_time']
                idx += 1
                totalcpu += cputime
                self.report_cpu_metric('cpu.%s.time' % idx, cputime, name)

            vcpus = dom.vcpusFlags(libvirt.VIR_DOMAIN_AFFECT_CONFIG)
            self.report_cpu_metric('cpu.total.time', totalcpu, name)
            self.publish('cpu.count', vcpus, instance=name)

            host_vcpus_provisioned += vcpus

            self.log.debug('%s -> instance vcpus(%d) host_vcpus_provisioned(%d)' % (name, vcpus, host_vcpus_provisioned))

            #
            # Disk stats
            disks = self.get_disk_devices(dom)
            accum = {}
            for stat in self.blockStats.keys():
                accum[stat] = 0

            for disk in disks:
                stats = dom.blockStats(disk)
                for stat in self.blockStats.keys():
                    idx = self.blockStats[stat]
                    val = stats[idx]
                    accum[stat] += val
                    self.publish_counter('block.%s.%s' % (disk, stat), val,
                                 instance=name)
            for stat in self.blockStats.keys():
                self.publish_counter('block.total.%s' % stat, accum[stat],
                             instance=name)

            # Network stats
            vifs = self.get_network_devices(dom)
            accum = {}
            for stat in self.vifStats.keys():
                accum[stat] = 0

            for vif in vifs:
                stats = dom.interfaceStats(vif)
                for stat in self.vifStats.keys():
                    idx = self.vifStats[stat]
                    val = stats[idx]
                    accum[stat] += val
                    self.publish_counter('net.%s.%s' % (vif, stat), val,
                                 instance=name)
            for stat in self.vifStats.keys():
                self.publish_counter('net.total.%s' % stat, accum[stat],
                             instance=name)

            # Memory stats
            mem = dom.memoryStats()
            self.publish('memory.nominal', mem['actual'] * 1024,
                         instance=name)
            self.publish('memory.rss', mem['rss'] * 1024, instance=name)

        if self.config['count_vms_by_state']:
            for k, v in host_dom_states.iteritems():
                if v is not None:
                    self.publish('vms.%s' % k, v)

        if self.config['count_provisioned_vcpus']:
            self.publish('vcpus', host_vcpus_provisioned)
