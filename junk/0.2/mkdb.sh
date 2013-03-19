#!/bin/bash

#set -x

# include parser
. /usr/lib/shflags/src/shflags

# define variables
DEFINE_string 'dbname' '' 'Name of new database. Will be random if not set.' 'n'
DEFINE_string 'dbuser' '' 'Username for new database.' 'u'
DEFINE_string 'dbpassword' '' 'Password for database+user. Will be random if not set.' 'p'

# parse variables
FLAGS "$@" || exit 1
eval set -- "${FLAGS_ARGV}"

# setting internal variables
if [[ ${FLAGS_dbuser} == "" ]] && [[ $dbuser == "" ]]
    then echo "Error. You have set --dbuser (-u) at least to create DB."; exit 1
elif [[ $dbuser != "" ]]
    then cdbuser=$dbuser
elif [[ ${FLAGS_dbuser} != "" ]]
    then cdbuser=${FLAGS_dbuser}
fi

if [[ $dbname != "" ]]
    then cdbname=$dbname
elif [[ ${FLAGS_dbname} != "" ]]
    then cdbname=${FLAGS_dbname}
elif [[ $dbname == "" ]] && [[ ${FLAGS_dbname} == "" ]]
    then cdbname=$(pwgen 10 -N 1 -A -0)
fi

if [[ $dbpassword != "" ]]
    then cdbpassword=$dbpassword
elif [[ ${FLAGS_dbpassword} != "" ]]
    then cdbpassword=${FLAGS_dbpassword}
elif [[ $dbpassword == "" ]] && [[ ${FLAGS_dbpassword} == "" ]]
    then cdbpassword=$(pwgen 15 -N 1 -A -0)
fi

# check, if database exist
mysql -e "use $cdbname;" 2>/dev/null 
if [[ $? == "0" ]]
    then echo "Sorry, but this database already exist. Choose another name with option \"--dbname\""; exit 1
fi

# create database:
mysql -e "create database \`$cdbname\`;"

# check created database:
mysql -e "use $cdbname;"
if [[ $? != "0" ]]
    then echo "Sorry, but i was not able to create this database for some reasons."
else echo "Database $cdbname created."
fi

# grant access to database: 
mysql -e "GRANT ALL ON \`$cdbname\`.* TO '$cdbuser'@'localhost' IDENTIFIED BY '$cdbpassword';"

# check is grants made:
mysql -u $cdbuser -p$cdbpassword -e "use $cdbname;"
if [[ $? != "0" ]]
    then echo "Sorry, but i was not able to create this database for some reasons."; exit 1
else echo "Access for user \"$cdbuser\" granted to $cdbname"
fi

echo -e "Password for user $cdbuser for $cdbname is:\n\t$cdbpassword"
echo -e "\nWarning! this information is wrote to file /etc/anlamp/mysql/$cdbname-$cdbuser.\nYou should delete this file as soon as possible with command:\n\trm -f /etc/anlamp/mysql/$cdbname-$cdbuser"
echo -e "Database: $cdbname\nUser: $cdbuser\nPassword: $cdbpassword" >> /etc/anlamp/mysql/$cdbname-$cdbuser
chmod 0600 /etc/anlamp/mysql/$cdbname-$cdbuser
