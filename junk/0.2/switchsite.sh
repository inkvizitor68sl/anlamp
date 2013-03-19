#!/bin/bash

# debug 
set -x

# include parser
. /usr/lib/shflags/src/shflags

# set variables from command line
DEFINE_string 'domain' 'null' 'Main domain name for new site, like example.com' 'd'
DEFINE_string 'state' 'null' 'state to make it now - can be "enable" or "disable" only' 's'

# parse variables
FLAGS "$@" || exit 1
eval set -- "${FLAGS_ARGV}"

# check variables.
if [[ ${FLAGS_domain} == "null" ]] 
      then echo "Error, You have to set --domain option (-d). Otherway i can't run this script"; exit 1
fi

if [[ ${FLAGS_state} != "disable" ]] && [[ ${FLAGS_state} != "enable" ]] &&[[ ${FLAGS_state} != "null" ]]
    then echo "--state/-s can be only "enable" or "disable". Leave this option, if you need to change state - it will disable enabled site or enable disabled site, according to state for thos moment"; exit 1
fi

# check is site enabled or disabled:
if [[ -e /etc/nginx/sites-enabled/${FLAGS_domain} ]] && [[ -e /etc/apache2/sites-enabled/${FLAGS_domain} ]]
    then echo "Site is enabled now"; flag=enabled
else echo "Site, probably, disabled now"; flag=disabled
fi


echo $flag
echo ${FLAGS_state}

# d

# restarting daemons:
#/etc/init.d/nginx reload
#apache2ctl reload