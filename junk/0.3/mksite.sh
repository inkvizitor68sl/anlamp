#!/bin/bash

# include parser
. /usr/lib/shflags/src/shflags

# set variables from command line
DEFINE_string 'domain' 'null' 'Main domain name for new site, like example.com' 'd'
DEFINE_string 'user' 'null' 'User, which one will be used to run the site' 'u'
DEFINE_string 'aliases' 'null' 'Additional domains for your site, like www.example.com' 'a'
DEFINE_string 'rootdir' 'null' 'root dir' 'r'
DEFINE_string 'email' 'null' 'ServerAdmin directive for apache and address for mail().' 'm'
DEFINE_boolean 'createdb' true 'create db?' 'c'
DEFINE_string 'dbname' '' 'Name for new database' 'n'
DEFINE_string 'dbpassword' '' 'Password for database+user' 'p'
DEFINE_string 'userpassword' 'null' 'FTP/SSH/SFTP password for user, if it not exist' 't'
DEFINE_boolean 'shell' false 'use --shell or -s, if you want to provide user ssh and sftp access' 's'

# parse variables
FLAGS "$@" || exit 1
eval set -- "${FLAGS_ARGV}"

# check variables.
if [[ ${FLAGS_domain} == "null" ]] 
      then echo "Error, You have to set --domain option (-d). Otherway we can't create your site"; exit 1
fi

if [[ ${FLAGS_user} == "null" ]]
      then echo "Error, You have to set --user option (-u). Otherway we can't create your site"; exit 1
else
    echo -e "We are creating now config files for ${FLAGS_domain} with user ${FLAGS_user}\n"
fi

# setting some var
if [[ ${FLAGS_rootdir} == "null" ]]
      then rootdir=/home/${FLAGS_user}/www/${FLAGS_domain}
else
    rootdir=${FLAGS_rootdir}
fi


# creating nginx config:
echo -e "server {
\tlisten 80;" >> /etc/anlamp/nginx/${FLAGS_domain}
if [[ ${FLAGS_aliases} == "null" ]]
      then echo -e "\tserver_name ${FLAGS_domain};"  >> /etc/anlamp/nginx/${FLAGS_domain}
else
    echo -e "\tserver_name ${FLAGS_domain} ${FLAGS_aliases};"  >> /etc/anlamp/nginx/${FLAGS_domain}
fi
echo -e "\troot $rootdir;
\tindex index.html index.php index.htm;
location / {
\tproxy_set_header X-Real-IP \$remote_addr;
\tproxy_set_header Host \$host;
\tproxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
\tproxy_pass http://127.0.0.1:81;
\terror_page 404 = @apache;
\t}
location ~^/phpmyadmin {
\tproxy_set_header X-Real-IP \$remote_addr;
\tproxy_set_header Host \$host;
\tproxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
\tproxy_pass http://127.0.0.1:81;
\terror_page 404 = @apache;
\t}
location ~*^.+\.(jpg|jpeg|gif|png|rar|txt|tar|wav|bz2|exe|pdf|doc|xls|ppt|bmp|rtf|js|ico|css|zip|tgz|gz)$ {
\troot $rootdir;
\texpires 30d;
\taccess_log off;
\t}
location ~ /\.ht {
\tdeny all;
\t}
location @apache {
\tproxy_set_header X-Real-IP \$remote_addr;
\tproxy_set_header Host \$host;
\tproxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
\tproxy_pass http://127.0.0.1:81;
\t}
}
" >> /etc/anlamp/nginx/${FLAGS_domain}

# creating apache config:
echo -e "<VirtualHost 127.0.0.1:81>
DocumentRoot $rootdir
ServerName ${FLAGS_domain}
AssignUserID ${FLAGS_user} ${FLAGS_user}" >> /etc/anlamp/apache/${FLAGS_domain}
if [[ ${FLAGS_aliases} == "null" ]]
      then echo 
else
    echo -e "ServerAlias ${FLAGS_aliases}" >> /etc/anlamp/apache/${FLAGS_domain}
fi
if [[ ${FLAGS_email} == "null" ]]
      then echo "ServerAdmin webmaster@${FLAGS_domain}" >> /etc/anlamp/apache/${FLAGS_domain}
else
    echo "ServerAdmin ${FLAGS_email}" >> /etc/anlamp/apache/${FLAGS_domain}
fi
echo "</VirtualHost>" >> /etc/anlamp/apache/${FLAGS_domain}

# creating db if we need it:
export dbuser=${FLAGS_user}
if [[ ${FLAGS_dbname} != "" ]]
    then export dbname=${FLAGS_dbname}
else 
    export dbname=$(echo ${FLAGS_domain} | tr "." "_")
fi
export dbpassword=${FLAGS_dbpassword}
if [[ ${FLAGS_createdb} == "0" ]]
	then /usr/bin/mkdb.sh
fi

# creating user if we need it:
export userpassword=${FLAGS_userpassword}
export eshell=${FLAGS_shell}
id ${FLAGS_user} 2>/dev/null 1>/dev/null
if [[ $? == 0 ]]
    then echo "user ${FLAGS_user} already exists."
else echo "Checking user ${FLAGS_user}:"; /usr/bin/mkuser.sh -u ${FLAGS_user}
fi

# enabling configuration at web-servers:
ln -s /etc/anlamp/nginx/${FLAGS_domain} /etc/nginx/sites-enabled/${FLAGS_domain}
ln -s /etc/anlamp/apache/${FLAGS_domain} /etc/apache2/sites-enabled/${FLAGS_domain}

# creating directories:
mkdir /home/${FLAGS_user}/www/${FLAGS_domain}
chown -R ${FLAGS_user}:${FLAGS_user} /home/${FLAGS_user}/www/${FLAGS_domain}

# creating default index:
echo -e "This default page for ${FLAGS_domain}.\nUse ftp or sftp to upload there files." >> /home/${FLAGS_user}/www/${FLAGS_domain}/index.html

/etc/init.d/nginx restart
/etc/init.d/apache2 restart
