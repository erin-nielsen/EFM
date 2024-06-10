e#####################################. Install_primary.sh. #############################################################

#!/bin/bash
# script to configure Primary server in 3 node streaming replication scenario
###   HOW TO USE THIS SCRIPT .  ##############################################
# Set up 3 nodes with CentOS7. The nodes must be able to communicate with each other
# Choose one of the nodes to be the PRIMARY.  The other two are REPLICA1 and REPLICA2
# Set the PRIMARY_IP variable below to the IP of the PRIMARY node
# Set the REPLICA1_IP and REPLICA2_IP below to the IP of the REPLICA1 and REPLICA2 nodes
# log into the node you've chosen to be the PRIMARY as 'root'
# Copy this script into the root users directory and execute it. YOU MUST EXECUTE THIS SCRIPTS AS THE 'root'user
# The script excecution must be attended as you will have to answer 'y' befpore the script completes.
# When the script has run to completion, you should see a line in the outpu indicating the version of postgres that is running
# You now have postgres running on the PRIMARY node and are ready to install the REPLICAs.  The REPLICAs
# will be kept in syunc with the PRIMARY using postrgres streaming replication.

 

# set the EDB_REPO_USR variable to your EDB Repository username
#EDB_REPO_USR=steve.egolf

# set the EDB_REPO_PWD variable to the password of the EDB Repository username you are using above
# EDB_REPO_PWD=gfkDTfCVqyHqB2KY

ADMIN_IP=0.0.0.0/0

read -p "Enter Primary node IP address: " p_ipaddr
echo "IP Address of Primary node: $p_ipaddr!"

 
read -p "Enter Replica1 IP address: " r1_ipaddr
echo "IP Address of Replica1 node: $r1_ipaddr!"

 
read -p "Enter Replica2 IP address: " r2_ipaddr
echo "IP Address of Replica2 node: $r2_ipaddr!"

 
read -p "Which node is this, i.e., Primary, Replica1, Replica2; " thisNode

 
PRIMARY_IP=$p_ipaddr
REPLICA1_IP=$r1_ipaddr
REPLICA2_IP=$r2_ipaddr

 

#############################################################################################################
#########  the following commands install the epas server   #################################################
#############################################################################################################

# prepare the repository
curl -1sLf 'https://downloads.enterprisedb.com/pdZe6pcnWIgmuqdR7v1L38rG6Z6wJEsY/enterprise/setup.rpm.sh' | sudo -E bash

# install the server
sudo dnf -y install edb-as15-server

#############################################################################################################
#########  the preceding commands install the epas server   #################################################
#############################################################################################################

cd /var/lib/edb 

sudo -s -u enterprisedb /usr/edb/as15/bin/initdb --pgdata=/var/lib/edb/as15/data
sudo -s -u enterprisedb /usr/edb/as15/bin/pg_ctl -D /var/lib/edb/as15/data/ stop
echo "host    replication    edbrepuser        $PRIMARY_IP/32          trust" | cat ->> /var/lib/edb/as15/data/pg_hba.conf
echo "host    replication    edbrepuser        $REPLICA1_IP/32         trust" | cat ->> /var/lib/edb/as15/data/pg_hba.conf
echo "host    replication    edbrepuser        $REPLICA2_IP/32         trust" | cat ->> /var/lib/edb/as15/data/pg_hba.conf

###  CAUTION!!!!  The following entry to pg_hba.conf opens up the database to all on the ADNIN_IP set above.  It is set to 0.0.0.0/0 above.  For saecurity you MUST set this
###  to your own value
echo "host    all            all               $ADMIN_IP               trust" | cat ->> /var/lib/edb/as15/data/pg_hba.conf

 

echo "archive_mode = on" | cat ->> /var/lib/edb/as15/data/postgresql.conf
echo "archive_command = 'cp %p /tmp/%f'" | cat ->> /var/lib/edb/as15/data/postgresql.conf

#############################################################################################################
#########  config in preparation for streaming replication   ################################################
#############################################################################################################
echo "listen_addresses = '*'"  | cat ->> /var/lib/edb/as15/data/postgresql.conf
echo "wal_level = replica" | cat ->> /var/lib/edb/as15/data/postgresql.conf
echo "wal_keep_size = 64" | cat ->> /var/lib/edb/as15/data/postgresql.conf
echo "max_wal_senders = 10" | cat ->> /var/lib/edb/as15/data/postgresql.conf
 

sudo -s -u enterprisedb /usr/edb/as15/bin/pg_ctl -D /var/lib/edb/as15/data/ -l /var/lib/edb/logfile start

sudo -s -u enterprisedb psql -d edb -c "select version();"
sudo -s -u enterprisedb psql -d edb -c "DROP USER IF EXISTS edbrepuser;"
sudo -s -u enterprisedb psql -d edb -c "CREATE ROLE edbrepuser WITH REPLICATION LOGIN PASSWORD 'postgres';"

##############################################################################################################