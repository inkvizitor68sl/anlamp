#!/bin/bash

# achtung! not ready at all!

# downloading and installing libshflags:
wget --no-check-certificate https://debian.pro/files/anlamp/libshflags_1.0.3-yandex1_all.deb
dpkg -i libshflags_1.0.3-yandex1_all.deb
rm libshflags_1.0.3-yandex1_all.deb

# downloading scripts:
wget --no-check-certificate https://debian.pro/files/anlamp/mksite.sh -O /usr/bin/mksite.sh && chmod +x /usr/bin/mksite.sh
wget --no-check-certificate https://debian.pro/files/anlamp/mkdb.sh -O /usr/bin/mkdb.sh && chmod +x /usr/bin/mkdb.sh
wget --no-check-certificate https://debian.pro/files/anlamp/mkuser.sh -O /usr/bin/mkuser.sh && chmod +x /usr/bin/mkuser.sh
wget --no-check-certificate https://debian.pro/files/anlamp/setmysqlrootpw.sh -O /usr/bin/setmysqlrootpw.sh && chmod +x /usr/bin/setmysqlrootpw.sh

# installing ftp:
echo "Do you need ftp server? yes/no"
read isftp

if [[ $isftp == "yes" ]]
	then apt-get install vsftpd; wget --no-check-certificate https://debian.pro/files/anlamp/configs/vsftpd.conf -O /etc/vsftpd.conf; /etc/init.d/vsftpd restart
fi

# installing nginx:
echo "deb http://backports.debian.org/debian-backports squeeze-backports main contrib non-free" >> /etc/apt/sources.list
apt-get update
apt-get --yes install -t squeeze-backports nginx

# installing other software:
apt-get ---yes install apache2 php5 libapache2-mod-php5 mysql-server mysql-client php5-mysql phpmyadmin apache2-mpm-itk curl pwgen

# installing config files:
wget --no-check-certificate https://debian.pro/files/anlamp/configs/apache2/ports.conf -O /etc/apache2/ports.conf
rm /etc/nginx/sites-enabled/*
wget --no-check-certificate https://debian.pro/files/anlamp/configs/nginx/default -O /etc/nginx/sites-enabled/default

# restarting web-servers
a2enmod rewrite
/etc/init.d/apache2 restart 
/etc/init.d/nginx restart

# mysql root:
/usr/bin/setmysqlrootpw.sh

# info about exim. 
echo "If you need to send mail from this server - read this, for example, https://debian.pro/276"

# creating dirs
mkdir -p /etc/anlamp/{nginx,apache,mysql}

