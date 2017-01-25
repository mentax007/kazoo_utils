#!/bin/bash
#######################################################################################################################################
## Automates some of "Deploying a Kazoo v4.0 cluster" steps 
## Intended to speed up configuration after cloning Kazoo configs from git
## Written by kirill.sysoev@gmail.com
#######################################################################################################################################

##############################################
## Create /etc/kz_vars/kazoo_config_edit.vars:
#
#WEBSOCKET_DOMAIN="tld.com"
#RABBIT_IP="192.168.4.100"
#HOMER_IP="192.168.4.99"
#
### If you changing Bigcouch cookie on already configured system do not forget 
### to change it at DB doc: system_config -> whistle_couch
#
#KZ_COOKIE="my_test_cookie"
#
#DB1="kz4100.tld.su 192.168.4.100"
#FS1="kz4100.tld.su"
#
## In case of cluster add:
##
##DB2="kz4103.tld.su 192.168.4.103"
##DB_BACKUP1="kz4104.tld.su 192.168.5.104"
##DB_BACKUP2="kz4105.tld.su 192.168.5.105"
##
##FS2="kz4101.tld.su"
##############################################

##source $(dirname $0)/kazoo_config_edit.vars
source /etc/kz_vars/kazoo_config_edit.vars

echo RABBIT_IP: $RABBIT_IP
echo DB1: $DB1
echo DB2: $DB2
echo DB_BACKUP1: $DB_BACKUP1
echo DB_BACKUP2: $DB_BACKUP2
echo FS1: $FS1
echo FS2: $FS2
echo KZ_COOKIE: $KZ_COOKIE


HOSTNAME=`hostname -f`
HOST_IP=`getent ahosts $HOSTNAME | cut -d' ' -f1 | head -n1`

echo Hostname: $HOSTNAME
echo Host_IP: $HOST_IP

echo "Disabling selinuxi...  just in case"

sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config 

echo "Disabling iptables ... just in case again"

chkconfig iptables off

echo "Setting up timezone and syncronization ... just in case again"

ln -fs /usr/share/zoneinfo/UTC /etc/localtime
/usr/bin/timedatectl set-ntp true

echo "Deleting previous configs"

rm -rf /etc/kazoo

echo "Retrieving KAZOO_CONFIGS master"

git clone -b 4.0 https://github.com/2600hz/kazoo_configs.git /etc/kazoo

if [ -d /etc/letsencrypt/live/$HOSTNAME ]; then
  mkdir /etc/kazoo/certs
  cp /etc/letsencrypt/live/$HOSTNAME/* /etc/kazoo/certs/
fi

## Kazoo Server step 3
echo "Kazoo Server step 3"

#Replace $RABBIT_IP with the IP address of the node that you are going to run the main RabbitMQ messaging bus on (generally the first Kazoo server)
#Replace $HOST_IP with the current host IP address
#Replace $HOSTNAME with the current host hostname
sed -i 's/guest:guest@127.0.0.1:5672/guest:guest@'$RABBIT_IP':5672/g' /etc/kazoo/kamailio/local.cfg
sed -i 's/127.0.0.1/'$HOST_IP'/g' /etc/kazoo/kamailio/local.cfg
sed -i 's/kamailio.2600hz.com/'$HOSTNAME'/g' /etc/kazoo/kamailio/local.cfg
sed -i 's/\#!substdef "!MY_WEBSOCKET_DOMAIN/\#\#!substdef "!MY_WEBSOCKET_DOMAIN/g' /etc/kazoo/kamailio/local.cfg

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

if [ -n "$DB_BACKUP1" ]; then
sed -i "s/db3.zone2.mydomain.com 127.0.0.3/$DB_BACKUP1/g" /etc/kazoo/haproxy/haproxy.cfg
else
sed -i "/db3.zone2.mydomain.com 127.0.0.3/d" /etc/kazoo/haproxy/haproxy.cfg
fi

if [ -n "$DB_BACKUP2" ]; then
sed -i "s/db4.zone2.mydomain.com 127.0.0.4/$DB_BACKUP2/g" /etc/kazoo/haproxy/haproxy.cfg
else
sed -i "/db4.zone2.mydomain.com 127.0.0.4/d" /etc/kazoo/haproxy/haproxy.cfg
fi

echo Done

echo Step 7

if [ -n "$FS1" ]; then
echo "1:1:sip\:$FS1\:11000:0:1: : " >> /etc/kazoo/kamailio/dbtext/dispatcher
fi
if [ -n "$FS2" ]; then
echo "2:1:sip\:$FS2\:11000:0:1: : " >> /etc/kazoo/kamailio/dbtext/dispatcher
fi
if [ -n "$FS1_GROUP2" ]; then
echo "3:2:sip\:$FS1_GROUP2\:11000:0:1: : " >> /etc/kazoo/kamailio/dbtext/dispatcher
fi
if [ -n "$FS2_GROUP2" ]; then
echo "4:2:sip\:$FS2_GROUP2\:11000:0:1: : " >> /etc/kazoo/kamailio/dbtext/dispatcher
fi

echo Done

echo Freeswitch kazoo.conf.xml editing

LineNum=`sed -n '/name="nodename"/{;=;}' /etc/kazoo/freeswitch/autoload_configs/kazoo.conf.xml`
sed -i '/name="nodename"/d' /etc/kazoo/freeswitch/autoload_configs/kazoo.conf.xml
sed -i $LineNum'i\        <param name="nodename" value="freeswitch@'$HOSTNAME'" />' /etc/kazoo/freeswitch/autoload_configs/kazoo.conf.xml

echo Done

#echo Freeswitch spandsp.conf.xml editing

#sed -i 's/param name="enable-t38"        value="true"/param name="enable-t38"        value="false"/g' /etc/kazoo/freeswitch/autoload_configs/spandsp.conf.xml
#sed -i 's/param name="enable-t38-request"        value="true"/param name="enable-t38-request"        value="false"/g' /etc/kazoo/freeswitch/autoload_configs/spandsp.conf.xml

#echo Done

echo RabbitMQ...

sed -i 's/guest:guest@127.0.0.1:5672/guest:guest@'$RABBIT_IP':5672/g' /etc/kazoo/core/config.ini

echo Cookies...

sed -i 's/cookie = change_me/cookie = '$KZ_COOKIE'/g' /etc/kazoo/core/config.ini 
sed -i 's/-setcookie change_me/-setcookie '$KZ_COOKIE'/g' /etc/kazoo/bigcouch/vm.args 
sed -i 's/name="cookie" value="change_me"/name="cookie" value="'$KZ_COOKIE'"/g' /etc/kazoo/freeswitch/autoload_configs/kazoo.conf.xml 

echo Homer functionality configuration

echo Kamailio..

RoutingLogicNum=`sed -n '/Routing Logic/{;=;}' /etc/kazoo/kamailio/default.cfg`

sed -i $((RoutingLogicNum-1))'i\ \
############################################################# \
################## Homer addition  ########################## \
############################################################# \
loadmodule "siptrace.so" \
# check IP and port of your capture node \
modparam("siptrace", "duplicate_uri","sip:'$HOMER_IP':9060"); \
modparam("siptrace", "hep_mode_on",1); \
modparam("siptrace", "trace_to_database",0); \
modparam("siptrace", "trace_flag",22); \
modparam("siptrace", "trace_on", 1); \
############################################################# \
' /etc/kazoo/kamailio/default.cfg

RoutingLogicNum=`sed -n '/Routing Logic/{;=;}' /etc/kazoo/kamailio/default.cfg`

sed -i $((RoutingLogicNum+3))'i\ \
############################################################# \
################## Homer addition  ########################## \
### start duplicate the SIP message now for Homer Logging ### \
############################################################# \
 \
        sip_trace(); \
        setflag(22); \
 \
############################################################# \
' /etc/kazoo/kamailio/default.cfg

echo FS...

sed -i '9i\        <param name="capture-server" value="udp:'$HOMER_IP':9060"/>'	/etc/kazoo/freeswitch/autoload_configs/sofia.conf.xml
LineNumSipTrace=`sed -n '/sip-trace/{;=;}' /etc/kazoo/freeswitch/sip_profiles/sipinterface_1.xml`
sed -i $LineNumSipTrace'i\            <param name="sip-capture" value="yes"/>' /etc/kazoo/freeswitch/sip_profiles/sipinterface_1.xml


## Check bigcouch.log rotating

sed -i 's/\/var\/log\/bigcouch.log {/\/var\/log\/bigcouch\/bigcouch.log {/' /etc/logrotate.d/bigcouch.conf

## Also could be worth after upgrade
#/opt/kazoo/utils/sup/sup whapps_maintenance refresh system_schemas
#/opt/kazoo/utils/sup/sup -t 3600 whapps_maintenance migrate


## FRONTIER

sed -i 's/# # #!trydef ACL_ROLE/#!trydef ACL_ROLE/g' /etc/kazoo/kamailio/local.cfg 
#sed -i 's/# # #!trydef RATE_LIMITER_ROLE/#!trydef RATE_LIMITER_ROLE/g' /etc/kazoo/kamailio/local.cfg 
sed -i 's/autoexpire=7200"/autoexpire=120"/g' /etc/kazoo/kamailio/acl-role.cfg 

## WSS

sed -i 's/# # #!trydef WEBSOCKETS_ROLE/#!trydef WEBSOCKETS_ROLE/g' /etc/kazoo/kamailio/local.cfg 
sed -i 's/MY_WEBSOCKET_DOMAIN!2600hz.com/MY_WEBSOCKET_DOMAIN!'$WEBSOCKET_DOMAIN'/g' /etc/kazoo/kamailio/local.cfg
sed -i 's/TLS_WSS!tls:MY_IP_ADDRESS:8443/TLS_WSS!tls:MY_IP_ADDRESS:9443/g' /etc/kazoo/kamailio/local.cfg
sed -i 's/UDP_WSS_SIP!udp:MY_IP_ADDRESS:8443/UDP_WSS_SIP!udp:MY_IP_ADDRESS:9443/g' /etc/kazoo/kamailio/local.cfg

## TLS

sed -i 's/# # #!trydef TLS_ROLE/#!trydef TLS_ROLE/g' /etc/kazoo/kamailio/local.cfg 
sed -i 's/<param name="tls" value="false"\/>/<param name="tls" value="true"\/>/g' /etc/kazoo/freeswitch/sip_profiles/sipinterface_1.xml
cp /etc/kazoo/certs/cert.pem /etc/kazoo/freeswitch/certs/agent.pem
cp /etc/kazoo/certs/fullchain.pem /etc/kazoo/freeswitch/certs/cacert.pem
cp /etc/kazoo/certs/cert.pem /etc/kazoo/kamailio/certs/cert.pem
cp /etc/kazoo/certs/privkey.pem /etc/kazoo/kamailio/certs/key.pem


## MONIT
## Bug atm: https://freeswitch.org/jira/browse/DOCS-52
#yum -y install wget
#yum -y install monit --enablerepo=epel --nogpgcheck
#wget https://raw.github.com/onnet/onnet_util/master/monit.conf -O /etc/monit.conf
#chmod 0600 /etc/monit.conf
#sed -i 's/change_mo_to_localsysname.onnet.su/'$HOSTNAME'/g' /etc/monit.conf
#rm -f /etc/monit.d/freeswitch.monitrc
#wget https://github.com/onnet/onnet_util/raw/master/freeswitch.monitrc -O /etc/monit.d/freeswitch.monitrc
#sed -i 's/change_mo_to_localsysname/'$HOSTNAME'/g' /etc/monit.d/freeswitch.monitrc
#chkconfig --add monit
#chkconfig monit on
#service monit restart

## Permissions

chown -R freeswitch.daemon /etc/kazoo/freeswitch
chown -R kamailio.kamailio /etc/kazoo/kamailio

echo HAProxy...

LineNumHAProxyGlobal=`sed -n '/stats socket/{;=;}' /etc/kazoo/haproxy/haproxy.cfg`
sed -i $((LineNumHAProxyGlobal + 1))'i\        tune.ssl.default-dh-param 2048' /etc/kazoo/haproxy/haproxy.cfg

LineNumHAProxyDefaults=`sed -n '/timeout server/{;=;}' /etc/kazoo/haproxy/haproxy.cfg`
sed -i $((LineNumHAProxyDefaults + 1))'i\        timeout tunnel 1h' /etc/kazoo/haproxy/haproxy.cfg

sed -i '$a \
 \
frontend secure_blackhole \
    bind 0.0.0.0:7777 ssl crt /etc/kazoo/haproxy/cert_key.pem \
    timeout client 1h \
    default_backend www_blackhole \
    acl is_websocket hdr(Upgrade) -i WebSocket \
    use_backend websocket_blackhole if is_websocket \
 \
backend www_blackhole \
    mode http \
    stats enable \
    stats uri /haproxy \
    option forwardfor \
    reqadd x-forwarded-proto:\\ https \
    server server1 127.0.0.1:5555 weight 1 maxconn 8192 \
 \
backend websocket_blackhole \
    mode http \
    option forwardfor \
    option http-server-close \
    option forceclose \
    no option httpclose \
    server server1 127.0.0.1:5555 weight 1 maxconn 8192 \

 ' /etc/kazoo/haproxy/haproxy.cfg

cat /etc/kazoo/certs/cert.pem > /etc/kazoo/haproxy/cert_key.pem
echo "" >> /etc/kazoo/haproxy/cert_key.pem
cat /etc/kazoo/certs/privkey.pem >> /etc/kazoo/haproxy/cert_key.pem

if [ -n "$ZONE1" ]; then
echo Rewrite config.ini in regards to zones

###sed -i d /etc/kazoo/core/config.ini
echo ';generated by kazoo_utils script: https://github.com/onnet' > /etc/kazoo/core/config.ini

sed -i '$a \
;\
[zone]\
name = "'$ZONE1'"\
amqp_uri = "amqp://guest:guest@'$ZONE1_RABBIT_IP':5672" \
\
[kazoo_apps]\
host = "'$ZONE1_APPS1'"\
zone = "'$ZONE1'"\
cookie = '$KZ_COOKIE'\
\
[kazoo_apps]\
host = "'$ZONE1_APPS2'"\
zone = "'$ZONE1'"\
cookie = '$KZ_COOKIE'\
\
[ecallmgr]\
host = "'$ZONE1_APPS1'"\
zone = "'$ZONE1'"\
cookie = '$KZ_COOKIE'\
\
[ecallmgr]\
host = "'$ZONE1_APPS2'"\
zone = "'$ZONE1'"\
cookie = '$KZ_COOKIE'\
' /etc/kazoo/core/config.ini

if [ -n "$ZONE2" ]; then

sed -i '$a \
[zone]\
name = "'$ZONE2'"\
amqp_uri = "amqp://guest:guest@'$ZONE2_RABBIT_IP':5672" \
\
[kazoo_apps]\
host = "'$ZONE2_APPS1'"\
zone = "'$ZONE2'"\
cookie = '$KZ_COOKIE'\
\
[kazoo_apps]\
host = "'$ZONE2_APPS2'"\
zone = "'$ZONE2'"\
cookie = '$KZ_COOKIE'\
\
[ecallmgr]\
host = "'$ZONE2_APPS1'"\
zone = "'$ZONE2'"\
cookie = '$KZ_COOKIE'\
\
[ecallmgr]\
host = "'$ZONE2_APPS2'"\
zone = "'$ZONE2'"\
cookie = '$KZ_COOKIE'\
' /etc/kazoo/core/config.ini

fi

sed -i '$a \
[bigcouch]\
compact_automatically = true\
cookie = '$KZ_COOKIE'\
ip = "127.0.0.1"\
port = 15984\
admin_port = 15986\
\
[log]\
syslog = debug\
console = debug\
file = debug' /etc/kazoo/core/config.ini

fi

if [ -n "$LOG_SYSLOG" ]; then
  sed -i 's/syslog = info/syslog = '$LOG_SYSLOG'/g' /etc/kazoo/core/config.ini
  sed -i 's/console = notice/console = '$LOG_SYSLOG'/g' /etc/kazoo/core/config.ini
  sed -i 's/file = error/file = '$LOG_SYSLOG'/g' /etc/kazoo/core/config.ini
fi

###  Just a hack to run non release
echo "-name kazoo_apps"  >> /etc/kazoo/core/vm.args
###
echo Done

