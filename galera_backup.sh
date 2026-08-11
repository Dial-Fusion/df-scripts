#!/bin/sh

# Setup info

MYSQLUSER="root"
MYSQLPASS=""
BACKUPDIR="/mnt/backups/current"
LOGFILE="$BACKUPDIR/galera_backup.log"

# Check if full backup exists and run if it doesn't

FULLDIR="$BACKUPDIR/backup-full"
INCLASTDIR="$FULLDIR"
echo "Check for full backup folder: $FULLDIR"

if [ ! -d "$FULLDIR" ]
then
  echo -e "Full Backup Folder Doesn't Exist! Starting Full Backup..\n"
  /usr/bin/mariabackup --backup --no-timestamp --target-dir=$FULLDIR --user $MYSQLUSER
  echo "Full Backup Completed! Exiting.."
  exit
else
  echo -e "Full Backup Folder Exists! Skipping Full Backup..\n"
fi

# Check for existing incremental backups and loop to find the last one

for((i=1; ;++i)); do
  INCDIR="$BACKUPDIR/backup-inc$i"
  echo "Checking for incremental backup folder: $INCDIR"
  if [ ! -d "$INCDIR" ]
  then
    echo "Doesn't exist! Starting incremental backup in $INCDIR"
    break
  else
    echo "Folder exists! Skipping to next.."
    INCLASTDIR="$INCDIR"
  fi
done

# Run incremental backup

echo "Running command: /usr/bin/mariabackup --backup --galera-info --no-timestamp --target-dir=$INCDIR --incremental-basedir=$INCLASTDIR --user $MYSQLUSER --password"
/usr/bin/mariabackup --backup --no-timestamp --target-dir=$INCDIR --incremental-basedir=$INCLASTDIR --user $MYSQLUSER
echo "Incremental Backup Completed! Exiting.."
exit

