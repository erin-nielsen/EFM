#!/bin/bash
###################################################################################
#Title           : EFM Script for making node to be a standby of EFM cluster
#                : on resume command
#Author          : Vibhor Kumar (vibhor.aim@gmail.com).
#Date            : Sept 3, 2020
#Version         : 1.0
#Notes           : Install Vim and Emacs to use this script.
#                : configure the .pgpass for EFM user and set
#                : the password correctly
#Bash_version    : GNU bash, version 4.2.46(2)-release (x86_64-redhat-linux-gnu)
###################################################################################

###################################################################################
# initialize all parameters
###################################################################################
readonly EFMBIN="/usr/edb/efm-4.7/bin"
readonly EFM="${EFMBIN}/efm"
readonly EFMREWIND="${EFMBIN}/efm_rewind.sh"
readonly EFM_ROOT_FUNCTION="${EFMBIN}/efm_root_functions"
readonly EFM_CLUSTER="efmdemo"
readonly PGOWNER="enterprisedb"

###################################################################################
# Make sure we have stopped the PG service
###################################################################################
sudo ${EFM_ROOT_FUNCTION} stopdbservice ${EFM_CLUSTER}

###################################################################################
# Get the Primary IP address from the  from the EFM command
###################################################################################

PRIMARY_HOST=$(sudo ${EFM} cluster-status ${EFM_CLUSTER} \
                      |grep -e Primary -e Master|head -n1|awk '{print $2}')

sudo -u ${PGOWNER} ${EFMREWIND} "${PRIMARY_HOST}" 2>&1 \
              | grep -v "could not change directory to"
sudo ${EFM_ROOT_FUNCTION} stopdbservice ${EFM_CLUSTER} 2>&1 \
              | grep -v "could not change directory to"

sudo ${EFM_ROOT_FUNCTION} startdbservice ${EFM_CLUSTER} 2>&1 \
              | grep -v "could not change directory to"
/usr/bin/sleep 10
sudo ${EFM} resume ${EFM_CLUSTER}
/usr/bin/sleep 10