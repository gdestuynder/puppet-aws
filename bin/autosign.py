#!/bin/env python
## populate /etc/puppet/autosign.conf based on tags

from boto.ec2 import connect_to_region, regions
from shutil import move
import sys
import os
import ConfigParser

config_file = "%s/.aws.cfg" % os.path.dirname(os.path.realpath(__file__))
config = ConfigParser.RawConfigParser()
config.read(config_file)

region = config.get('aws', 'region')
aws_id = config.get('aws', 'id')
aws_secret = config.get('aws', 'secret')

autosign = '/etc/puppet/autosign.conf'
temp = '%s.tmp' % autosign
filters = {'tag:Project': 'amo'}

try:
    conn = connect_to_region(region, aws_access_key_id=aws_id,
                            aws_secret_access_key=aws_secret)
    reservations = conn.get_all_instances(filters=filters)
    private_dns = [i.private_dns_name for r in reservations
                   for i in r.instances]

    private_dns = filter(None, private_dns)
    with open(temp, 'w') as fp:
        for i in private_dns:
            fp.write(i + '\n')
        move(temp, autosign)
except:
    print sys.exc_info()