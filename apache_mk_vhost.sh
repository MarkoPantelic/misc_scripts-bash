#!/bin/bash

#=================================================
#
# Skript koji kreira Apache config xml stavku 
# za 'non-ip vhost'
#
#================================================


CONFD=/opt/lampp/etc/extra/
CONF=httpd-vhosts.conf
HOSTSF=/etc/hosts
XAMPPEXE=/opt/lampp/xampp


function chkdir() 
{
	if [ ! -d "$1" ]; then
		echo "Neispravna zadata putanja direktorijuma $2 - '$1'";
		exit 1;
	fi
}


# echo apache direktive za httpd-vhost.conf
function advhost() 
{
echo "
<VirtualHost *:80>
    DocumentRoot \"$2\"
    ServerName $1
    <Directory \"$2\">
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
	echo "Skript se mora pokrenuti sa 'sudo' komandom";
	exit 1;
fi



if [ $# -lt 2 ]; then
	echo "Skript zahteva dva argumenta (arg1 localhost, arg2 direktorijum):";
	echo "Primer:";
	echo "./mkvhost.sh projekat1.localhost /home/backend-prepodne/Desktop/workspace.php/projekat1";
	exit 1;
fi

LOCALHOST=$1
DIR=$2


chkdir $CONFD "za konfig vhost fajl";
chkdir $DIR "za lokaciju 'project' direktorijuma";

if [ ! -f "$CONFD$CONF" ]; then
	echo "Neispravan naziv konfig fajla - '$CONF'";
	exit 1;
elif [ ! -w "$CONFD$CONF" ]; then
	echo "Neispravne dozvole za pisanje fajla - '$CONF'";
	exit 1;
fi




#main()

# proveri da li vec postoji host u /etc/hosts
grep $LOCALHOST\$ $HOSTSF 1>/dev/null
if [ $? -eq 0 ]; then
	echo "NAPOMENA: za host '$LOCALHOST' već postoji linija u '$HOSTSF'"
	read trash;
	echo "kraj skripte";
	exit 0;
fi

# proveri da li vec ima unos za taj direktorijum u vhost
grep -E "$DIR\"" $CONFD$CONF 1>/dev/null
if [ $? -eq 0 ]; then
	echo "NAPOMENA: već postoji direktiva sa direktorijumom '$DIR' u '$CONF'"
	read trash;
	echo "kraj skripte"
	exit 0;
fi

echo "'ip-host' linija u '$HOSTSF' bi bila:";
linkhost $LOCALHOST;

echo " ";

echo "'Apache vhost' direktiva u '$CONFD$CONF' bi bila:";
advhost $LOCALHOST $DIR;

echo " ";

echo "Ukoliko odgovaraju podešavanja, ukucaj 'da'. U suprotnom 'ne'."

a=0;
while [ ! $a -eq 1 ]; do

	read -p "da ili ne: " answer

	if [ "$answer" == "da" ]; then
		a=1
	elif [ "$answer" == "ne" ]; then
		echo "kraj skripte";
		exit 0;
	else
		echo "isključivo 'da' ili 'ne'"
	fi
done


echo "Kreiram ip-host stavku u '$HOSTSF' fajlu";
linkhost $LOCALHOST >> $HOSTSF;

echo "Kreiram 'vhost' stavku u '$CONFD$CONF'";
advhost $LOCALHOST $DIR >> $CONFD$CONF;

echo "Uspešno kreirane stavke.";
echo " ";

echo "Da li da skript startuje XAMPP?";

a=0;
while [ ! $a -eq 1 ]; do

	read -p "da ili ne: " answer

	if [ "$answer" == "da" ]; then

		res=`$XAMPPEXE start 2>/dev/null`
		echo "$res";

		if [ $? -eq 0 ]; then
			echo "XAMPP uspešno startovan";
		else
			# !!! trenutno nevalidno. $XAMPPEXE prosledjuje gresku u /dev/null 
			echo "dogodila se greška prilikom startovanja XAMPP-a";
			exit 1;
		fi
		exit 0;
	elif [ "$answer" == "ne" ]; then
		echo "Kraj skripte.";
		exit 0;
	else
		echo "isključivo 'da' ili 'ne'"
	fi
done

