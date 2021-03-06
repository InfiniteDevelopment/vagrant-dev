#!/bin/bash

#
# Provisioning for mysql
#
# @author Herberto Graca <herberto.graca@gmail.com>
#
# Version: 1.0.0

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. ${DIR}/../settings.sh

DEPENDENCIES=(  )

# ==================================================================
#
# MAIN
#
# ------------------------------------------------------------------


echo
echo "Installing dependencies ... "
echo
install_apps DEPENDENCIES[@]


# get environment from argument if it exist
if [ $# -ne 0 ]; then
    ENV=$1
fi

export DEBIAN_FRONTEND='noninteractive'

apt-get update

apt-get -q -y install mysql-server mysql-client

mysqladmin -u root password ${MYSQL_ROOT_PASS}

export DEBIAN_FRONTEND=''

# Allow connections from outside 127.0.0.1
IP='127.0.0.1'
cp /etc/mysql/my.cnf /etc/mysql/my.cnf.bkp
cat /etc/mysql/my.cnf.bkp | sed -e "s@^bind-address.*= ${IP}@bind-address=\"0.0.0.0\"@" > /etc/mysql/my.cnf

# Allow root to connect from 192.168.1.1 TODO HG: get this IP from the config
IP='192.168.1.1'
mysql -u root -pxpto -e "CREATE USER 'root'@'${IP}' IDENTIFIED BY '${MYSQL_ROOT_PASS}';"
mysql -u root -pxpto -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'${IP}' IDENTIFIED BY '${MYSQL_ROOT_PASS}' WITH GRANT OPTION MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0 ;"

# prevent from starting at boot
if [ "${IN_VAGRANT_BOX}" == "0" ]; then
    echo "manual" >> /etc/init/mysql.override
fi


exit 0

