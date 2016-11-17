# Some notes for CentOS7 based Kazoo 4.0 installation
##Preps
- selinux permissive
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
- systemctl enable shorewall.service


## Bigcouch
- yum install bigcouch --nogpgcheck
- systemctl enable kazoo-bigcouch.service
```
curl -X PUT core5-dc01-dev.sip.local:5986/nodes/bigcouch@core6-dc01-dev.sip.local -d {}
curl -X PUT core5-dc01-dev.sip.local:5986/nodes/bigcouch@core7-dc01-dev.sip.local -d {}
curl -X PUT core5-dc01-dev.sip.local:5986/nodes/bigcouch@core5-dc02-dev.sip.local -d {}
curl -X PUT core5-dc01-dev.sip.local:5986/nodes/bigcouch@core6-dc02-dev.sip.local -d {}
curl -X PUT core5-dc01-dev.sip.local:5986/nodes/bigcouch@core7-dc02-dev.sip.local -d {}
```

## FS
- yum install -y http://files.freeswitch.org/freeswitch-release-1-6.noarch.rpm epel-release
- yum install kazoo-freeswitch freeswitch-application-av freeswitch-format-shout 
- systemctl enable epmd.service

## Kamailio + Kazoo Apps
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
- vi /etc/default/kamailio - check startup vars

### Kazoo
- yum install kazoo-core* kazoo-app*
- systemctl enable kazoo-applications.service
- systemctl enable kazoo-ecallmgr.service
- systemctl enable kazoo-haproxy.service
- systemctl enable kazoo-kamailio.service

## First steps

- sup crossbar_maintenance create_account {ACCT NAME} {REALM} {LOGIN} {PASSWORD}
- sup -n ecallmgr ecallmgr_maintenance add_fs_node freeswitch@...

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
