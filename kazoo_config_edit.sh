#!/bin/bash
#######################################################################################################################################
## Automates some of "Deploying a Kazoo v3.0 cluster" steps ( https://2600hz.atlassian.net/wiki/pages/viewpage.action?pageId=39223316 )
## Intended to speed up configuration after cloning Kazoo configs from git
## Written by kirill.sysoev@gmail.com
#######################################################################################################################################

##############################################
## Create /etc/kz_vars/kazoo_config_edit.vars:
#
#RABBIT_IP="94.125.4.100"
#
#DB1="kz4100.onnet.su 94.125.4.100"
#FS1="kz4100.onnet.su"
#
## In case of cluster add:
##
##DB2="kz4103.onnet.su 94.125.4.103"
##DB3="kz4104.onnet.su 94.125.4.104"
##DB4="kz4105.onnet.su 94.125.4.105"
##
##FS2="kz4101.onnet.su"
##############################################

##source $(dirname $0)/kazoo_config_edit.vars
source /etc/kz_vars/kazoo_config_edit.vars

echo RABBIT_IP: $RABBIT_IP
echo DB1: $DB1
echo DB2: $DB2
echo DB3: $DB3
echo DB4: $DB4
echo FS1: $FS1
echo FS2: $FS2


HOSTNAME=`hostname -f`
HOST_IP=`hostname -I | cut -d' ' -f1`

echo Hostname: $HOSTNAME
echo Host_IP: $HOST_IP

echo "Disabling selinuxi...  just in case"

sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config 

echo "Disabling iptables... just in case again"

chkconfig iptables off

echo "Deleting previous configs"

rm -rf /etc/kazoo

echo "Retrieving KAZOO_CONFIGS master"

git clone https://github.com/2600hz/kazoo_configs.git /etc/kazoo

## Kazoo Server step 3
echo "Kazoo Server step 3"

#Replace $RABBIT_IP with the IP address of the node that you are going to run the main RabbitMQ messaging bus on (generally the first Kazoo server)
#Replace $HOST_IP with the current host IP address
#Replace $HOSTNAME with the current host hostname
sed -i 's/guest:guest@127.0.0.1:5672\/dialoginfo/guest:guest@'$RABBIT_IP':5672\/dialoginfo/g' /etc/kazoo/kamailio/local.cfg
sed -i 's/guest:guest@127.0.0.1:5672\/callmgr/guest:guest@'$RABBIT_IP':5672\/callmgr/g' /etc/kazoo/kamailio/local.cfg
sed -i 's/127.0.0.1/'$HOST_IP'/g' /etc/kazoo/kamailio/local.cfg
sed -i 's/kamailio.2600hz.com/'$HOSTNAME'/g' /etc/kazoo/kamailio/local.cfg

echo Done

echo Step 4 and 5

rm -rf /etc/haproxy/haproxy.cfg
ln -s /etc/kazoo/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg

sed -i "s/db1.zone1.mydomain.com 127.0.0.1/$DB1/g" /etc/kazoo/haproxy/haproxy.cfg

if [ -n "$DB2" ]; then
sed -i "s/db2.zone1.mydomain.com 127.0.0.2/$DB2/g" /etc/kazoo/haproxy/haproxy.cfg
else
sed -i "/db2.zone1.mydomain.com 127.0.0.2/d" /etc/kazoo/haproxy/haproxy.cfg
fi

if [ -n "$DB3" ]; then
sed -i "s/db3.zone2.mydomain.com 127.0.0.3/$DB3/g" /etc/kazoo/haproxy/haproxy.cfg
else
sed -i "/db3.zone2.mydomain.com 127.0.0.3/d" /etc/kazoo/haproxy/haproxy.cfg
fi

if [ -n "$DB4" ]; then
sed -i "s/db4.zone2.mydomain.com 127.0.0.4/$DB4/g" /etc/kazoo/haproxy/haproxy.cfg
else
sed -i "/db4.zone2.mydomain.com 127.0.0.4/d" /etc/kazoo/haproxy/haproxy.cfg
fi

echo Done

echo Step 7

sed -i "s/1 sip:127.0.0.1:11000 0/1 sip:$FS1:11000 0/" /etc/kazoo/kamailio/dbtext/dispatcher
if [ -n "$FS2" ]; then
echo 1 sip:$FS2:11000 0 >> /etc/kazoo/kamailio/dbtext/dispatcher
fi

echo Done

echo Freeswitch kazoo.conf.xml editing

LineNum=`sed -n '/name="nodename"/{;=;}' /etc/kazoo/freeswitch/autoload_configs/kazoo.conf.xml`
sed -i '/name="nodename"/d' /etc/kazoo/freeswitch/autoload_configs/kazoo.conf.xml
sed -i $LineNum'i\        <param name="nodename" value="freeswitch@'$HOSTNAME'" />' /etc/kazoo/freeswitch/autoload_configs/kazoo.conf.xml

echo Done

