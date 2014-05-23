#!/bin/bash
#Description:
#This script only runs on Centos 6.5 64bit


# check root permissions
if [[ $UID != 0 ]]; then
    echo "Please run this script as root or sudo!"
    exit 1
fi

#------------VARIABLE------------
ARC=$(/bin/uname -m)

##TEXT COLOR
COLOR_LIGHT_GREEN='\033[1;32m'
COLOR_LIGHT_BLUE='\033[1;34m'
COLOR_YELLOW='\033[1;33m'
COLOR_RED='\033[0;31m'
COLOR_WHITE='\033[1;37m'
COLOR_DEFAULT='\033[0m'



##----------PREPARATION-----------
#check system machine architectre
if [ $ARC != 'x86_64' ]; then
    echo $ARC, " i386 compatible"
    echo "This program is only capable for x64 systems"
    exit 1
else
    echo "System [" $ARC "]detected...${COLOR_RED}[OK]${COLOR_DEFAULT}"
fi 


## Disable SELINUX
/usr/sbin/setenforce 0
/bin/sed -i.org -e 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

## Edit Kernel Parameter to enable Routing
#change curernt parameter
/bin/echo '1' > /proc/sys/net/ipv4/ip_forward
/bin/echo '0' > /proc/sys/net/ipv4/conf/default/rp_filter

#edit sysctl.conf
/bin/sed -i.org -e 's/net.ipv4.ip_forward = 0/net.ipv4_ip_forward = 1/g' /etc/sysctl.conf
/bin/sed -i.org -e 's/net.ipv4.conf.default.rp_filter = 1/net.ipv4.conf.default.rp_filter = 0/g' /etc/sysctl.conf

#add more variable
/bin/cat << _SYSCTLCONF_ >> /etc/sysctl.conf
net.ipv4.conf.all.rp_filter = 0
net.ipv4.conf.all.forwarding = 1
_SYSCTLCONF_

#edit /etc/rc.local
/bin/echo 'echo 0 > /proc/sys/net/bridge/bridge-nf-call-iptables' >> /etc/rc.local
/bin/echo 'echo 0 > /proc/sys/net/bridge/bridge-nf-call-ip6tables' >> /etc/rc.local
/bin/echo 'echo 0 > /proc/sys/net/bridge/bridge-nf-call-arptables' >> /etc/rc.local

/sbin/sysctl -p /etc/sysctl.conf

## add EPEL repo
/bin/rpm --import http://ftp.riken.jp/Linux/fedora/epel/RPM-GPG-KEY-EPEL-6
/bin/rpm -ivh http://ftp.riken.jp/Linux/fedora/epel/6/${ARC}/epel-release-6-8.noarch.rpm
/bin/sed -i.org -e "s/enabled.*=.*1/enabled=0/g" /etc/yum.repos.d/epel.repo

#add RDO Havana repo
/usr/bin/yum install -y http://repos.fedorapeople.org/repos/openstack/openstack-havana/rdo-release-havana-8.noarch.rpm
#update package
/usr/bin/yum -y update

echo "${COLOR_LIGHT_BLUE}Inital configuration is done."
echo "${COLOR_RED}Please reboot the system to apply all of the configuration${COLOR_DEFAULT}"

