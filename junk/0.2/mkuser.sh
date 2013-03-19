#!/bin/bash

#set -x

# include parser
. /usr/lib/shflags/src/shflags

# define variables
DEFINE_string 'user' 'null' 'User, which one will be used to run the sites' 'u'
DEFINE_string 'password' 'null' 'Password for new user (unsecure!)' 'p'
DEFINE_boolean 'shell' false 'use --shell or -s, if you want to provide user ssh and sftp access' 's'

# parse variables
FLAGS "$@" || exit 1
eval set -- "${FLAGS_ARGV}"

# check, if --user set:
if [[ ${FLAGS_user} == null ]]
    then echo "You have to set --user(-u) option as the name of new user. I am can't create user without it."; exit 1
fi

# check, if user exist:
id ${FLAGS_user} 1>/dev/null 2>/dev/null
if [[ $? == 0 ]]
    then echo "user ${FLAGS_user} already exists."; exit 1
else echo "Creating user ${FLAGS_user}:"
fi

# set password, random if empty.
if [[ $userpassword != "" ]]
    then cuserpassword=$userpassword
elif [[ ${FLAGS_password} != "null" ]]
    then cuserpassword=${FLAGS_password}
else cuserpassword=$(pwgen 15 -N 1 -A -0)
fi

# choosing shell for user: 
if [[ ${FLAGS_shell} == 1 ]]
    then cshell=/bin/date
elif [[ ${FLAGS_shell} == 0 ]]
    then cshell=/bin/bash
fi

#creating user: 
/usr/sbin/useradd -d /home/${FLAGS_user} -m ${FLAGS_user} -s $cshell

#setting password:
echo -e "$cuserpassword\n$cuserpassword\n" | passwd ${FLAGS_user} 1>/dev/null 2>/dev/null

#creating some directories:
mkdir /home/${FLAGS_user}/{www,tmp,.ssh}
chown -R ${FLAGS_user}:${FLAGS_user} /home/${FLAGS_user}

#check is user created:
id ${FLAGS_user} 1>/dev/null 2>/dev/null
if [[ $? != 0 ]]
    then echo "Sorry, but i am failed to create this user for some reasons"; exit 1
fi

#Output:
echo "I am created user \"${FLAGS_user}\" for you"
echo "His password - $cuserpassword"
if [[ $cshell == "/bin/date" ]]
    then echo "This user have FTP access only."
elif [[ $cshell == "/bin/bash" ]]
    then echo "This user have SSH/SFTP/FTP access."
fi
