#!/bin/bash

#Description:
#   Continuous script from ready_stack.sh
#   This program installs RDO Havana

#variables
#Dashboard admin password
PASS='admin'


#NIC
NIC1='eth0' #PUBLIC NETWORK NIC
NIC2='lo'   #PRIVATE NETWORK NIC
#NIC3='eth3'

#Static IP
IPADDR='192.168.1.244'
NETMASK='255.255.255.0'
GATEWAY='192.168.1.1'


##TEXT COLOR
COLOR_LIGHT_GREEN='\033[1;32m'
COLOR_LIGHT_BLUE='\033[1;34m'
COLOR_YELLOW='\033[1;33m'
COLOR_RED='\033[0;31m'
COLOR_WHITE='\033[1;37m'
COLOR_DEFAULT='\033[0m'


#Check ROOT permission
if [[ $UID != 0 ]]; then
    echo -e "${COLOR_RED}Please run this script as root or sudo!${COLOR_DEFAULT}"
    exit 1
else
    echo -e "${COLOR_LIGHT_BLUE}ROOT/SUDO run\t\t\t${COLOR_LIGHT_GREEN}[OK]${COLOR_DEFAULT}"
    echo -e "${COLOR_RED}Static IP address"
    echo -e "${COLOR_LIGHT_GREEN}IPADDR=${COLOR_YELLOW}192.168.1.244"
    echo -e "${COLOR_LIGHT_GREEN}NETMASK=${COLOR_YELLOW}255.255.255.0"
    echo -e "${COLOR_LIGHT_GREEN}GATEWAY=${COLOR_YELLOW}192.168.1.1"


    #----------Install RDO-------------------
    /usr/bin/yum -y install openstack-packstack python-netaddr
    
    
    #Create answer file
    /usr/bin/packstack --gen-answer-file=/root/answer.txt
    
    #Edit Answer file
    #NOVA CONFIG
    /bin/sed -i.org -e 's/CONFIG_NOVA_COMPUTE_PRIVIF=*/CONFIG_NOVA_COMPUTE_PRIVIF=$NIC2/g' /root/answer.txt
    /bin/sed -i.org -e 's/CONFIG_NOVA_NETWORK_PRIVIF=*/CONFIG_NOVA_NETWORK_PRIVIF=$NIC2/g' /root/answer.txt
    /bin/sed -i.org -e 's/CONFIG_NOVA_NETWORK_PUBIF=*/CONFIG_NOVA_NETWORK_PUBIF=$NIC1/g' /root/answer.txt
    
    #KEYSTONE CONFIG -admin password
    /bin/sed -i.org -e 's/CONFIG_KEYSTONE_ADMIN_PW=*/CONFIG_KEYSTONE_ADMIN_PW=$PASS/g' /root/answer.txt
    
    #disable DEMO account/network
    /bin/sed -i.org -e 's/CONFIG_PROVISION_DEMO=*/CONFIG_PROVISION_DEMO=n/g' /root/answer.txt
    
    
    #Run packstack with customized answer file
    /usr/bin/packstack --answer-file=/root/answer.txt
    
    #-----------Create NIC Configuration files-----------------
    #config backup
    /bin/cp /etc/sysconfig/network-scripts/ifcfg-eth0 /etc/sysconfig/network-scripts/ifcfg-eth0.org
    
    
    #HWaddr ID of NIC1 (public network)
    HW_NIC1=`ifconfig $NIC1 | awk '/HWaddr/ {print $5}'`
    /bin/cp ./conf/ifcfg-public.temp ./conf/ifcfg-$NIC1
    /bin/sed -i.org -e "s/HWADDR=/HWADDR=\"$HW_NIC1\"/g" ./conf/ifcfg-eth0
    
    #Bridge setup
    /bin/cp ./conf/ifcfg-bridge.temp ./conf/ifcfg-br-ex
    /bin/sed -i.org -e "s/IPADDR=/IPADDR=$IPADDR/g" ./conf/ifcfg-br-ex
    /bin/sed -i.org -e "s/GATEWAY=/GATEWAY=$GATEWAY/g" ./conf/ifcfg-br-ex
    /bin/sed -i.org -e "s/NETMASK=/NETMASK=$NETMASK/g" ./conf/ifcfg-br-ex
    
    #copy configs
    /bin/cp -f ./conf/ifcfg-$NIC1 /etc/sysconfig/network-scripts/ifcfg-$NIC1
    /bin/cp -f ./conf/ifcfg-br-ex /etc/sysconfig/network-scripts/ifcfg-br-ex
    
    #neutron plugin setup
fi #check root
