#!/bin/bash

#============================================================
#
# Script which creates Apache vhost entry for 'non-ip vhost'
# and creates /etc/hosts entry
#
# author: Marko Pantelic
#============================================================


CONFD=/opt/lampp/etc/extra/
CONF=httpd-vhosts.conf
HOSTSF=/etc/hosts
XAMPPEXE=/opt/lampp/xampp


function chkdir() 
{
	if [ ! -d "$1" ]; then
		echo "Directory path invalid $2 - '$1'";
		exit 1;
	fi
}


# echo directive for httpd-vhost.conf
function advhost() 
{
echo "
<VirtualHost *:80>
    DocumentRoot \"$2\"
    ServerName $1
    <Directory \"$2\">
        Options Indexes FollowSymLinks Includes ExecCGI
        AllowOverride all
        Order deny,allow
        Require all granted
    </Directory>
</VirtualHost>
";
}


function linkhost() 
{
	echo -e "127.0.0.1\t$1";
}



if [ "$EUID" -ne 0 ]; then
	echo "'$0' script must be invoked with 'sudo' privileges";
	exit 1;
fi



if [ $# -lt 2 ]; then
	echo "'$0' script requires two arguments (arg1 localhost, arg2 directory path):";
	echo "Example:";
	echo "$0 project.localhost /path/to/some/folder/";
	exit 1;
fi

LOCALHOST=$1
DIR=$2


chkdir $CONFD "for config vhosts file";
chkdir $DIR "for location of 'project' directory";

if [ ! -f "$CONFD$CONF" ]; then
	echo "$0: Invalid name of config file - '$CONF'";
	exit 1;
elif [ ! -w "$CONFD$CONF" ]; then
	echo "$0: No permission for writing file - '$CONF'";
	exit 1;
fi




#main()

# Check if there is already a hostname which is equal to the given name in /etc/hosts
grep $LOCALHOST\$ $HOSTSF 1>/dev/null
if [ $? -eq 0 ]; then
	echo "Warning: for host '$LOCALHOST' there is already an entry in '$HOSTSF'"
	read trash;
	echo "End script";
	exit 0;
fi

# Check if there is already an entry with a given directory path in vhosts file
grep -E "$DIR\"" $CONFD$CONF 1>/dev/null
if [ $? -eq 0 ]; then
	echo "Warning: entry present in vhosts file for given directory path '$DIR' u '$CONF'"
	read trash;
	echo "End script"
	exit 0;
fi

echo "'ip-host' line in '$HOSTSF' will bi set like:";
linkhost $LOCALHOST;

echo " ";

echo "'Apache vhost' directive '$CONFD$CONF' will be set like:";
advhost $LOCALHOST $DIR;

echo " ";

echo "If OK, enter 'yes'. Otherwise 'no'."

a=0;
while [ ! $a -eq 1 ]; do

	read -p "yes or no: " answer

	if [ "$answer" == "yes" ]; then
		a=1
	elif [ "$answer" == "no" ]; then
		echo "End script";
		exit 0;
	else
		echo "Exclusively 'yes' or 'no'"
	fi
done


echo "Creating ip-host entry in '$HOSTSF' file";
linkhost $LOCALHOST >> $HOSTSF;

echo "Creating 'vhost' entry in '$CONFD$CONF'";
advhost $LOCALHOST $DIR >> $CONFD$CONF;

echo "Success.";
echo " ";


echo "restarting apache, in order for changes to take effect";
$XAMPPEXE reloadapache 2>/dev/null

#echo "Should we start XAMPP?";

#a=0;
#while [ ! $a -eq 1 ]; do
#
#	read -p "yes or no: " answer
#
#	if [ "$answer" == "yes" ]; then
#
#		res=`$XAMPPEXE start 2>/dev/null`
#		echo "$res";
#
#		if [ $? -eq 0 ]; then
#			echo "XAMPP started";
#		else
#			# !!! Invalid error catch. XAMPP sends error messages to > /dev/null 
#			echo "Error encountered when trying to start XAMPP";
#			exit 1;
#		fi
#		exit 0;
#	elif [ "$answer" == "ne" ]; then
#		echo "End script.";
#		exit 0;
#	else
#		echo "Exclusively 'yes' or 'no'"
#	fi
#done
#
