#!/bin/bash

# debug:
# set -x

# checking is we root:
if [[ $(whoami) != "root" ]]
    then echo "You have to run this script as root user only!"; exit 1
fi

# asking for password:
echo "Tell me your mysql root password to save it to ~/.my.cnf:"
read password

touch ~/.my.cnf

# writing info:
cat ~/.my.cnf | grep "password = "
if [[ $? == "0"  ]]
    then sed -i "s/password = .*/password = $password/g" ~/.my.cnf
elif [[ $? == "1" ]]
    then  cat ~/.my.cnf | grep "[client]"; answer=$?
    if [[ $answer == "1" ]]
	then echo -e "[client]\npassword = $password\n" >> ~/.my.cnf
    elif [[ $answer == "0" ]]
	then sed -i "s/\[client\]/\[client\]\npassword = $password\n/" ~/.my.cnf
    fi
else echo "some error ocured, bugreport to root@vlad.pro, please"
fi

# chmod/chown:
chown root:root ~/.my.cnf
chmod 0600 ~/.my.cnf

# disclaimer:
echo "Warning, your password saved in ~/.my.cnf file. Only root can read this file, but anyway be carefull."
