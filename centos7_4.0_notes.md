
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


