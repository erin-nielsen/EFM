# script to configure Replica server in 3 node streaming replication scenario
# this script should only be run on the servers identified to be the REPLICAs in the cluster.
# NOTE:  There is another script that MUST already have been run on the PRIMARY node.

# PREREQUISITES THAT MUST BE COMPLETE BEFORE RUNNING THIS SCRIPT
#
# Set up a three compute instances, bare metal or virtual, with CentOS7 as the operating sytem
# Choose one of the nodes to be the PRIMARY.  This is the only node that will be open for read/write operations
# Copy this script to each of the nodes you've identified as REPLICAs
# Set the PRIMARY_IP variable below with the IP address of the node you've chosen to be the PRIMARY
# Execute this script.  YOU MUST EXECUTE THIS SCRIPTT AS THE 'root' user
# The script excecution MUST be attended as you will have to answer 'y' before the script completes.
# When the script has run to completion, you should see a line in the output indicating the version of postgres that is running
# You now have postgres running on the REPLICA node.  The REPLICA node
# will be kept in syunc with the PRIMARY using postrgres streaming replication.

read -p "Enter Primary node IP address: " p_ipaddr
echo "IP Address of Primary node: $p_ipaddr!"

PRIMARY_IP=$p_ipaddr

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

echo "*:5444:*:edbrepuser:password" | cat -> /var/lib/edb/.pgpass
chmod 600 /var/lib/edb/.pgpass
chown enterprisedb:enterprisedb /var/lib/edb/.pgpass


sudo -s -u enterprisedb /usr/edb/as15/bin/pg_ctl -D /var/lib/edb/as15/data/ stop


rm -rf /var/lib/edb/as15/data/
sudo -s -u enterprisedb /usr/edb/as15/bin/pg_basebackup -D /var/lib/edb/as15/data -R --host=$PRIMARY_IP --port=5444 --username=edbrepuser -w

echo "primary_conninfo = 'host=$PRIMARY_IP port=5444 user=edbrepuser'" | cat ->> /var/lib/edb/as15/data/postgresql.conf


#############################################################################################################
#########  configure this server as a read-only replica     #################################################
#############################################################################################################
echo "hot_standby = on" | cat ->> /var/lib/edb/as15/data/postgresql.conf


sudo -s -u enterprisedb /usr/edb/as15/bin/pg_ctl -D /var/lib/edb/as15/data/ -l /var/lib/edb/logfile start