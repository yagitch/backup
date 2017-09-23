#!/bin/sh

CLOUDDIR=https://dav.box.com/dav
TODAY=`date '+%Y%m%d'`_`hostname`
DIST=/var/box
BKDIR=/usr/local/bin
BKFILELIST=backupfile.lst
BKDIRLIST=backupdir.lst
cat $BKDIR/$BKFILELIST > /tmp/backup.tmp

mysqldump -u root -x --all-databases --events > /tmp/backup-db.sql
echo "/tmp/backup-db.sql" >> /tmp/backup.tmp
crontab -l > /tmp/crontab.txt
echo "/tmp/crontab.txt" >> /tmp/backup.tmp

# マウント
mount -t davfs $CLOUDDIR $DIST
mkdir $DIST/$TODAY
cd $DIST/$TODAY

# リストをバックアップ
echo "[$BKFILELIST]"
while read LINE1; do
  rsync -a $LINE1 .
  echo $LINE1
done < /tmp/backup.tmp

echo "[$BKDIRLIST]"
while read LINE2; do
  rsync -rptgoD $LINE2 .
  echo $LINE2
done < $BKDIR/$BKDIRLIST

# 後処理
umount $DIST
rm /tmp/backup.tmp
rm /tmp/backup-db.sql
rm /tmp/crontab.txt
exit
