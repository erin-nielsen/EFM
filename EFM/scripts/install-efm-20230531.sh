#!/bin/bash
# databse version 15, either community or EDB Advanced Server or postgres extended


dnf -y install java

read -p "Is this installation for community postgres or EDB postgres, i.e., Comm, EDB; " dbType

if [ $dbType == "Comm" ]
then
    # prepare repository
    echo "Prepare repository"
    curl -1sLf 'https://downloads.enterprisedb.com/pdZe6pcnWIgmuqdR7v1L38rG6Z6wJEsY/enterprise/setup.rpm.sh' | sudo -E bash
else
    echo "Repository already set up"
fi

# install EFM
sudo dnf -y install edb-efm46

cd /etc/edb/efm-4.6

cp efm.properties.in efm.properties

cp efm.nodes.in efm.nodes

chown efm:efm efm.properties

chown efm:efm efm.nodes

read -p "Enter Primary node IP address: " p_ipaddr
echo "IP Address of Primary node: $p_ipaddr!"

read -p "Enter Replica1 IP address: " r1_ipaddr
echo "IP Address of Replica1 node: $r1_ipaddr!"

read -p "Enter Replica2 IP address: " r2_ipaddr
echo "IP Address of Replica2 node: $r2_ipaddr!"

read -p "Which node is this, i.e., Primary, Replica1, Replica2; " thisNode

echo "$p_ipaddr:7800" | cat -  > /etc/edb/efm-4.6/efm.nodes

echo "$r1_ipaddr:7800" | cat -  >> /etc/edb/efm-4.6/efm.nodes

echo "$r2_ipaddr:7800" | cat -  >> /etc/edb/efm-4.6/efm.nodes


if [ $thisNode == "Primary" ]
then
    IPADDR=$p_ipaddr 
elif [ $thisNode == "Replica1" ]
then
    IPADDR=$r1_ipaddr
elif [ $thisNode == "Replica2" ] 
then
    IPADDR=$r2_ipaddr
else
    echo "Incorrect values for node designations!! The designation must be typed exactly as shown, i.e., Primary, Replica1, Replica2 "
    exit
fi

EFMPASS=postgres
export EFMPASS 

#########################################################
# Update the efm.properties File
#########################################################
if [ $dbType == "EDB" ]
then
    ###############################################################################################################################################
    ########################################################### update for EDB postgres ###########################################################
    sed -i -e 's/db.user=/db.user=enterprisedb/g' /etc/edb/efm-4.6/efm.properties             # The name of the database user.       
    sed -i -e "s/db.password.encrypted=/db.password.encrypted=$(/usr/edb/efm-4.6/bin/efm encrypt efm --from-env)/g"   /etc/edb/efm-4.6/efm.properties # The encrypted password of the database user.
    sed -i -e 's/db.port=/db.port=5444/g'  /etc/edb/efm-4.6/efm.properties                        # The port monitored by the database.
    sed -i -e 's/db.database=/db.database=edb/g'  /etc/edb/efm-4.6/efm.properties                 # The name of the database.
    sed -i -e 's/db.service.owner=/db.service.owner=enterprisedb/g'  /etc/edb/efm-4.6/efm.properties   # owner of the data directory 
                                                                                                       # (usually postgres or enterprisedb). 
                                                                                                       # Required only if the database is running as a service.
    sed -i -e 's/db.service.name=/db.service.name=/g'  /etc/edb/efm-4.6/efm.properties        # The name of the database service (used to restart the server). 
                                                                                              # Required onlyif the database is running as a service.
    sed -i -e 's/db.data.dir=/db.data.dir=\/var\/lib\/edb\/as15\/data/g'  /etc/edb/efm-4.6/efm.properties        
    sed -i -e 's/db.bin=/db.bin=\/usr\/edb\/as15\/bin/g'  /etc/edb/efm-4.6/efm.properties                 # The path to the bin directory (used for calls to pg_ctl).
    sed -i -e 's/db.recovery.dir=/db.recovery.dir=\/var\/lib\/edb\/as15\/data/g'  /etc/edb/efm-4.6/efm.properties        # The data directory in which EFM will find or create
                                                                                                                         # the recovery.conf file or the standby.signal file.
    sed -i -e 's/user.email=/user.email=s@q.com/g'  /etc/edb/efm-4.6/efm.properties   # An email address at which to receive email notifications 
                                                                                      # (notification text is also in the agent log file).
    sed -i -e "s/bind.address=/bind.address=$IPADDR:7800/g"  /etc/edb/efm-4.6/efm.properties  # The local address of the node and the port to use for EFM. 
                                                                                              # The format is: bind.address=1.2.3.4:7800
    sed -i -e 's/is.witness=/is.witness=false/g' /etc/edb/efm-4.6/efm.properties     # true on a witness node and false if it is a primary or standby.
    sed -i -e 's/ping.server.ip=/ping.server.ip=/g' /etc/edb/efm-4.6/efm.properties  # If you are running on a network without Internet access, set
                                                                                     # ping.server.ip to an address that is available on your network.
    sed -i -e 's/auto.allow.hosts=false/auto.allow.hosts=true/g' /etc/edb/efm-4.6/efm.properties    # On a test cluster, set to true to simplify startup; 
                                                                                                    # for production usage, consult the user’s guide.
    sed -i -e 's/stable.nodes.file=false/stable.nodes.file=true/g' /etc/edb/efm-4.6/efm.properties   # On a test cluster, set to true to simplify startup; 
                                                                                                     # for production usage, consult the user’s guide.
########################################################### update for EDB postgres ###########################################################                                                               
###############################################################################################################################################
elif [ $dbType == "Comm" ]
then
#####################################################################################################################################################
########################################################### update for Community postgres ###########################################################
    sed -i -e 's/db.user=/db.user=postgres/g' /etc/edb/efm-4.6/efm.properties             # The name of the database user.       
    sed -i -e "s/db.password.encrypted=/db.password.encrypted=$(/usr/edb/efm-4.6/bin/efm encrypt efm --from-env)/g"   /etc/edb/efm-4.6/efm.properties # The encrypted password of the database user.
    sed -i -e 's/db.port=/db.port=5432/g'  /etc/edb/efm-4.6/efm.properties                        # The port monitored by the database.
    sed -i -e 's/db.database=/db.database=postgres/g'  /etc/edb/efm-4.6/efm.properties                 # The name of the database.
    sed -i -e 's/db.service.owner=/db.service.owner=postgres/g'  /etc/edb/efm-4.6/efm.properties   # owner of the data directory 
                                                                                                   # (usually postgres or enterprisedb). 
                                                                                                   # Required only if the database is running as a service.
    sed -i -e 's/db.service.name=/db.service.name=/g'  /etc/edb/efm-4.6/efm.properties        # The name of the database service (used to restart the server). 
                                                                                          # Required onlyif the database is running as a service.
    sed -i -e 's/db.data.dir=/db.data.dir=\/var\/lib\/pgsql\/15\/data/g'  /etc/edb/efm-4.6/efm.properties        
    sed -i -e 's/db.bin=/db.bin=\/usr\/pgsql-15\/bin/g'  /etc/edb/efm-4.6/efm.properties                 # The path to the bin directory (used for calls to pg_ctl).
    sed -i -e 's/db.recovery.dir=/db.recovery.dir=\/var\/lib\/pgsql\/15\/data/g'  /etc/edb/efm-4.6/efm.properties        # The data directory in which EFM will find or create
                                                                                                                         # the recovery.conf file or the standby.signal file.
    sed -i -e 's/user.email=/user.email=s@q.com/g'  /etc/edb/efm-4.6/efm.properties   # An email address at which to receive email notifications 
                                                                                 # (notification text is also in the agent log file).
    sed -i -e "s/bind.address=/bind.address=$IPADDR:7800/g"  /etc/edb/efm-4.6/efm.properties  # The local address of the node and the port to use for EFM. 
                                                                                           # The format is: bind.address=1.2.3.4:7800
    sed -i -e 's/is.witness=/is.witness=false/g' /etc/edb/efm-4.6/efm.properties     # true on a witness node and false if it is a primary or standby.
    sed -i -e 's/ping.server.ip=/ping.server.ip=<SET IP ADDRESS APPROPRIATELY>/g' /etc/edb/efm-4.6/efm.properties  # If you are running on a network without Internet access, set
                                                                                 # ping.server.ip to an address that is available on your network.
    sed -i -e 's/auto.allow.hosts=false/auto.allow.hosts=true/g' /etc/edb/efm-4.6/efm.properties    # On a test cluster, set to true to simplify startup; 
                                                                                           # for production usage, consult the user’s guide.
    sed -i -e 's/stable.nodes.file=false/stable.nodes.file=true/g' /etc/edb/efm-4.6/efm.properties   # On a test cluster, set to true to simplify startup; 
                                                                                            # for production usage, consult the user’s guide.
########################################################### update for Community postgres ########################################################### 
#####################################################################################################################################################
else
    echo "You entered the database type incorrectly so you need to run the script again"
    exit
fi

echo "script complete!!  you can now start efm using -     systemctl start edb-efm-4.6     "
#########################################################
#########################################################
