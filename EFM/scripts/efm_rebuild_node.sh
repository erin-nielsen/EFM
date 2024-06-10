#!/bin/bash

run_and_log() {
  echo "$@"
  "$@"
}
# Redirect both stdout and stderr to the console and a log file
exec > /dev/tty 2>&1

echo "Shut down EFM Agent Running"
run_and_log sudo systemctl stop edb-efm-4.7.service
/usr/bin/sleep 10

# operate restore as enterprisedb
echo "Run the following commands as enterprisedb"
sudo -u enterprisedb bash << EOF
echo "Now running as: \$(whoami)"

# remove data directory
echo "Remove data directory contents"
rm -rf /opt/postgres/data/*

echo "Perform backup."
pg_basebackup -h 10.33.158.189 -D /opt/postgres/data -P -U enterprisedb --wal-method=stream -R
EOF

/usr/bin/sleep 10
echo "Now running as: $(whoami)"
echo "Start the EFM Service."
run_and_log sudo systemctl start edb-efm-4.7.service

/usr/bin/sleep 10

echo "Start the postgres db service."
run_and_log sudo systemctl start postgres.service

/usr/bin/sleep 10

echo "Restart EFM agent"
run_and_log sudo systemctl restart edb-efm-4.7.service


