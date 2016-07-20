#!/usr/bin/env bash

set -e

/usr/share/zookeeper-3.4.8/bin/zkServer.sh start /usr/share/zookeeper-3.4.8/conf/zoo.cfg
/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf