#!/bin/bash

testfile=/mnt/wasabi/storage-attached
targetdate=`/usr/bin/date -d 'today - 1 days' +%F`

if [ -f "$testfile" ]; then
    echo "Wasabi file exists. Proceeding."
    echo "Processing Managed Dial Fusion recordings"
    /usr/bin/cp -Rv /home/archive/$targetdate/ /mnt/wasabi/
    /usr/bin/rm -rf /home/archive/$targetdate
    /usr/bin/ln -s /mnt/wasabi/$targetdate/ /home/archive/$targetdate
    /usr/bin/chown cronarchive:users /home/archive/$targetdate

    echo "Processing Zest BPO Dedicated Dial Fusion recordings"
    /usr/bin/cp -Rv /home/archive1064/$targetdate/ /mnt/wasabi/zestbpo/
    /usr/bin/rm -rf /home/archive1064/$targetdate
    /usr/bin/ln -s /mnt/wasabi/zestbpo/$targetdate/ /home/archive1064/$targetdate
    /usr/bin/chown archive1064:users /home/archive1064/$targetdate

    /sbin/fstrim -av
else
    echo "Wasabi file does not exist. Aborting move."
    exit 1
fi
