#!/bin/bash

# Setup info

BACKUPDIR="/mnt/backup/vicidial"

# Make new folder for today's date

# now=$(date +"%Y-%m-%d")
# if [ ! -d "$BACKUPDIR/$now" ]
# then
#   mkdir ${now}
# fi

# daily

if [ -d "$BACKUPDIR/daily" ]
then
  # rotate
  echo "Daily exists"

  for((i=2;i>0;i--)); do
    if [ -d "$BACKUPDIR/daily.$i" ]
    then
      if [ $i -eq 1 ]
      then
        echo "Removing $BACKUPDIR/daily.$i"
        rm -fR "$BACKUPDIR/daily.$i"
      else
        echo "Moving $BACKUPDIR/daily.$i to $BACKUPDIR/daily.$((i+1))"
        mv "$BACKUPDIR/daily.$i" "$BACKUPDIR/daily.$((i+1))"
      fi
    fi
  done

  echo "Moving $BACKUPDIR/daily to $BACKUPDIR/daily.1"
  mv "$BACKUPDIR/daily" "$BACKUPDIR/daily.1"
fi

echo "Creating directory $BACKUPDIR/daily"
mkdir "$BACKUPDIR/daily"

echo "Copying $BACKUPDIR/current/* to $BACKUPDIR/daily"
cp -Rp "$BACKUPDIR/current"/* "$BACKUPDIR/daily"

# prepare current backup and remove incrementals

echo "Preparing current backup - $BACKUPDIR/current/backup-full"
/usr/bin/mariabackup --prepare --target-dir="$BACKUPDIR/current/backup-full"

for((i=1; ;++i)); do
  INCDIR="$BACKUPDIR/current/backup-inc$i"
  if [ ! -d "$INCDIR" ]
  then
    break
  else
    echo "Merging incremental backup - $INCDIR"
    /usr/bin/mariabackup --prepare --target-dir="$BACKUPDIR/current/backup-full" --incremental-dir="$INCDIR"

    echo "Removing $INCDIR"
    rm -fR "$INCDIR"
  fi
done
chown -R nobody: /mnt/backup/vicidial
