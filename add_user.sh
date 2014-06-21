#!/bin/bash -x
#add users to keystone

uname='user1'



##TEXT COLOR
COLOR_LIGHT_GREEN='\033[1;32m'
COLOR_LIGHT_BLUE='\033[1;34m'
COLOR_YELLOW='\033[1;33m'
COLOR_RED='\033[0;31m'
COLOR_WHITE='\033[1;37m'
COLOR_DEFAULT='\033[0m'

SUBNET1='172.16.13.0/24'


#Check ROOT permission
if [[ $UID != 0 ]]; then
    echo -e "${COLOR_RED}Please run this script as root or sudo!${COLOR_DEFAULT}"
    exit 1
else


#add user
keystone tenant-create --name $uname --enable true
echo "$uname added"
#check status
keystone tenant-list

#create password
keystone user-create --name user1 --pass user1 --tenant admin --email test@example.com --enable true

#add user1 in project admin
