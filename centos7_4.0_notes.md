# Some notes for CentOS7 based Kazoo 4.0 installation
##Preps
- selinux permissive
- ln -fs /usr/share/zoneinfo/UTC /etc/localtime
- vi /etc/yum.repos.d/2600hz.repo
```
[kazoo40]
name=Kazoo 4.0
baseurl=https://packages.2600hz.com/centos/7/staging/
enabled=1
sslverify=0
gpgcheck=0
```
- yum -y install epel-release
- yum -y install shorewall
```
###################  Cluster IPs  ##################################
ACCEPT    net:xxx.xxx.xxx.xxx/xx fw
###################  Crossbar HTTP, HTTPS  #########################
ACCEPT    net                   $FW     tcp     8000
ACCEPT    net                   $FW     tcp     8443
###################  SIP ###########################################
ACCEPT    net                   $FW     tcp     5060,7000
ACCEPT    net                   $FW     udp     5060,7000
###################  TLS ###########################################
ACCEPT    net                   $FW     tcp     5061,7001
###################  Kamailio Websockets WS, WSS  ##################
ACCEPT    net                   $FW     tcp     5064,5065
ACCEPT    net                   $FW     udp     5064,5065
###################  Blackhole WS, WSS  ############################
ACCEPT    net                   $FW     tcp     5555
ACCEPT    net                   $FW     tcp     7777
####################################################################
```
- systemctl enable shorewall.service


## Bigcouch servers
- yum install -y kazoo-bigcouch
- systemctl enable kazoo-bigcouch
- systemctl start kazoo-bigcouch
```
curl -X PUT core5-dc01-dev.sip.local:5986/nodes/bigcouch@core6-dc01-dev.sip.local -d {}
curl -X PUT core5-dc01-dev.sip.local:5986/nodes/bigcouch@core7-dc01-dev.sip.local -d {}
curl -X PUT core5-dc01-dev.sip.local:5986/nodes/bigcouch@core5-dc02-dev.sip.local -d {}
curl -X PUT core5-dc01-dev.sip.local:5986/nodes/bigcouch@core6-dc02-dev.sip.local -d {}
curl -X PUT core5-dc01-dev.sip.local:5986/nodes/bigcouch@core7-dc02-dev.sip.local -d {}
```
- curl localhost:5984/_membership | python -mjson.tool

## FS server
- yum -y install kazoo-haproxy
- yum install -y http://files.freeswitch.org/freeswitch-release-1-6.noarch.rpm epel-release
- yum install kazoo-freeswitch freeswitch-application-av freeswitch-format-shout kazoo-sounds-freeswitch*
- systemctl enable epmd.service
- systemctl enable kazoo-haproxy.service

## Rabbit + Kamailio + Kazoo Apps server

### Rabbit (it is way better to keep it on separate server(s). it is resources hungry and reboots slowly)
- yum install https://www.rabbitmq.com/releases/rabbitmq-server/v3.6.0/rabbitmq-server-3.6.0-1.noarch.rpm
- yum install kazoo-configs-rabbitmq
- chkconfig rabbitmq-server on

### Kamailio
- vi /etc/yum.repos.d/kamailio.repo
```
[home_kamailio_v4.4.x-rpms]
name=RPM Packages for Kamailio v4.4.x (CentOS_7)
type=rpm-md
baseurl=http://download.opensuse.org/repositories/home:/kamailio:/v4.4.x-rpms/CentOS_7/
gpgcheck=1
gpgkey=http://download.opensuse.org/repositories/home:/kamailio:/v4.4.x-rpms/CentOS_7//repodata/repomd.xml.key
enabled=1
```
- yum install kazoo-configs-kamailio kamailio-kazo* kamailio-outbound kamailio-uuid
- rm -rf /etc/kamailio
- ln -s /etc/kazoo/kamailio /etc/kamailio
- systemctl enable kazoo-kamailio.service
- chkconfig --del kamailio
- vi /etc/default/kamailio - check startup vars
- new dbtext format: 1:1:sip\:fs.tld.com\:11000:0:1: : (check kamailio/local.cfg)

### Kazoo
- yum -y install kazoo-core* kazoo-app* kazoo-sounds-core*
- yum -y install kazoo-haproxy
- systemctl enable kazoo-applications.service
- systemctl enable kazoo-ecallmgr.service
- systemctl enable kazoo-haproxy.service
- systemctl enable kazoo-kamailio.service

## Erlang for dev
- yum install libxslt-devel zip unzip expat zlib-devel curl ncurses-devel git-core htmldoc gcc gcc-c++ openssl-devel expat-devel
```
curl -O https://raw.githubusercontent.com/yrashk/kerl/master/kerl
chmod a+x kerl
mv kerl /usr/bin
kerl list releases
kerl build 18.2 r18.2
kerl install r18.2 /usr/local/erlang
. /usr/local/erlang/activate

vi .bashrc
. /usr/local/erlang/activate
```

## First steps

- sup crossbar_maintenance create_account {ACCT NAME} {REALM} {LOGIN} {PASSWORD}
- sup -n ecallmgr ecallmgr_maintenance add_fs_node freeswitch@...
- sup kazoo_media_maintenance import_prompts /opt/kazoo/sounds/en/us/
- sup kazoo_media_maintenance import_prompts /opt/kazoo/sounds/ru/ru ru-ru

## Letsencrypt SSL cert
- yum install certbot
- certbot certonly --standalone -d \`hostname -f\`
- mkdir /etc/kazoo/certs
- cp /etc/letsencrypt/live/\`hostname -f\`/* /etc/kazoo/certs/
- edit crossbar doc
```
"use_ssl": true,
"ssl_port": "8443",
"ssl_cert": "/etc/kazoo/certs/cert.pem",
"ssl_key": "/etc/kazoo/certs/privkey.pem",
"ssl_ca_cert": "/etc/kazoo/certs/fullchain.pem",
```

## SRV notes
```
_sip._udp.sip1.tld.com.  10 10 5060 core1-dc01.tld.com.
_sip._udp.sip1.tld.com.  10 10 5060 core2-dc01.tld.com.
_sip._udp.sip1.tld.com.  20 20 5060 core1-dc02.tld.com.
_sip._udp.sip1.tld.com.  20 20 5060 core2-dc02.tld.com.

_sip._udp.sip2.tld.com.  10 10 5060 core1-dc02.tld.com.
_sip._udp.sip2.tld.com.  10 10 5060 core2-dc02.tld.com.
_sip._udp.sip2.tld.com.  20 20 5060 core1-dc01.tld.com.
_sip._udp.sip2.tld.com.  20 20 5060 core2-dc01.tld.com.
```
