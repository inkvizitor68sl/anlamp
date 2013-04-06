#!/bin/bash

set_vars () {
### There are we can configure some options. By default you should do nothing there, until you know what to do ;)
# which dir should we backup. To be universal script we are backuping / (all files on server, except excluded at exclude-list).
files_to_backup=/

# mysql databases list
db_list=$(/usr/bin/mysql -e 'show databases;' | egrep -v '("+--"|Database|information_schema|performance_schema)')

# backup date/time - will figure at mysqldumps name.
backupdate=$(date +%Y%m%d-%H%M)

backup_dest=/backup

# where should we keep files backup. 
backup_dest_files=${backup_dest}/files/

# where should we keep mysqldumps
backup_dest_mysqldumps=${backup_dest}/mysqldumps/

# exclude list - this files/dirs will not be backuped by rdiff_backup()
exclude_list=/etc/backup/exclude.list

# how many days should we keep old mysql dumps. Set amount of days to keep. 
keep_mysql_dumps=5

### end of configure section.
}

rdiff_backup () {
/usr/bin/rdiff-backup --print-statistics --exclude-sockets --preserve-numerical-ids --exclude-globbing-filelist ${exclude_list} ${files_to_backup} ${backup_dest}
}

mysql_dumps () {
# creating dumps
for i in $db_list; do mysqldump $i > ${backup_dest_mysqldumps}/"${i}-${backupdate}".sql; done

# gzipping existing dumps:
for i in `ls ${backup_dest_mysqldumps}*.sql`; do gzip $i; done

# removing backups older, than ${keep_mysql_dumps}
find ${backup_dest_mysqldumps} -ctime  +${keep_mysql_dumps} -exec rm -f {} \;  -print 

}

set_vars
rdiff_backup
mysql_dumps
