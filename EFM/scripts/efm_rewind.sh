#!/bin/bash

###################################################################################
#Title           : EFMcript for making node to be a standby of EFM cluster
#                : on resume command
#Author          : Vibhor Kumar (vibhor.aim@gmail.com).
#Date            : Sept 3, 2020
#Version         : 1.0
#Notes           : Install Vim and Emacs to use this script.
#                : configure the .pgpass for EFM user and set
#                : the password correctly. Make sure we have /etc/hosts updated
#                : with the hosts and IP address. In this script we capture
#                : hostname from /etc/hosts to set the application name
#Bash_version    : GNU bash, version 4.2.46(2)-release (x86_64-redhat-linux-gnu)
###################################################################################
###################################################################################
# initialize all parameters
###################################################################################
readonly PGENGINE='/usr/edb/as16/bin'
readonly PG_CTL="${PGENGINE}/pg_ctl"
readonly PSQL="${PGENGINE}/psql -qAt"
readonly PG_REWIND="${PGENGINE}/pg_rewind"
readonly PGPASSWORD="EaesJ#sHEexJdfvymSk4WVYlX!khzsSe"
readonly PGDATA="/opt/postgres/data"
readonly PGUSER="enterprisedb"
readonly PGDATABASE="edb"
readonly PGPORT="5444"

readonly PGOWNER="enterprisedb"
readonly PGHOST="$1"

###################################################################################
# export the require environment
###################################################################################
export PGUSER PGDATABASE PGPORT PGHOST PGDATA

###################################################################################
# check if we have primary host
###################################################################################

if [[ -z ${PGHOST} ]]
then
  echo "ERROR: primary host not found"
  echo "Usage: $0 < Primary Host ip address >"
  exit 0
fi

#################################################################op##################
# Get the host from /etc/hosts based on the IP address
###################################################################################
CURRENT_IP=$(/usr/sbin/ifconfig -a|grep inet|head -n1|awk '{print $2}')
CURRENT_HOST=$(grep ${CURRENT_IP} /etc/hosts|awk '/pg/ {print $2}')

###################################################################################
# remove recovery.conf file if it exists
###################################################################################
rm -f ${PGDATA}/recovery.conf

###################################################################################
# start the PG with different port and shutdown
###################################################################################

${PG_CTL} start -D ${PGDATA} -o "-p 54999" >/dev/null
${PG_CTL} stop -D ${PGDATA} -o "-p 54999" >/dev/null

###################################################################################
# run the rewind command for PGDATA
###################################################################################

${PG_REWIND} --target-pgdata=${PGDATA} --source-server="host=${PGHOST} dbname=edb"

###################################################################################
# create a standby.signal file and update the primary slot and conninfo  /usr/edb/as15/bin
###################################################################################
PRIMARY_CONNECTION="user=${PGUSER} password=${PGPASSWORD}"
PRIMARY_CONNECTION="${PRIMARY_CONNECTION} host=${PGHOST}"
PRIMARY_CONNECTION="${PRIMARY_CONNECTION} port=${PGPORT}"
PRIMARY_CONNECTION="${PRIMARY_CONNECTION} application_name=''${CURRENT_HOST}''"

/bin/sed -i -e '/primary_conninfo/d' -e '/primary_slot_name/d' \
   ${PGDATA}/postgresql.auto.conf

/bin/echo "primary_conninfo = '${PRIMARY_CONNECTION}'" \
      >> ${PGDATA}/postgresql.auto.conf
/bin/echo "primary_slot_name = '${CURRENT_HOST}'" \
  >> ${PGDATA}/postgresql.auto.conf

/bin/touch ${PGDATA}/standby.signal