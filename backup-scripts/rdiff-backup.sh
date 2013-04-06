#!/bin/bash

set_vars () {
chroot_dest=/
db_list=$(chroot ${chroot_dest}/ /usr/bin/mysql -e 'show databases;' | egrep -v '("+--"|Database|mysql|information_schema|performance_schema)')
backupdate=$(date +%Y%m%d-%H%M)
backup_dest=/backup
backup_dest_chroot=${backup_dest}/rootfs/
backup_dest_mysqldumps=${backup_dest}/mysqldumps/
exclude_list=/etc/backup/exclude.list
}

rdiff_backup () {
#set -x
/usr/bin/rdiff-backup --print-statistics --exclude-sockets --preserve-numerical-ids --exclude-globbing-filelist ${exclude_list} ${chroot_dest} ${backup_dest_chroot}
}

mysql_dumps () {
#set -x
# creating dumps:
#for i in $db_list; do chroot ${chroot_dest} /usr/bin/mysqldump $i > ${backup_dest_mysqldumps}/"$i-${backupdate}".sql; done
for i in $db_list; do chroot ${chroot_dest} /opt/mysql/server-5.6/bin/mysqldump $i > ${backup_dest_mysqldumps}/"$i-${backupdate}".sql; done


# gzipping existing dumps:
for i in `ls ${backup_dest_mysqldumps}*.sql`; do gzip $i; done

# removing backups older, than 5 days
find ${backup_dest_mysqldumps} -ctime  +5 -exec rm -f {} \;  -print 
}

set_vars
rdiff_backup
mysql_dumps

