#!/bin/bash

#----------------------------------------#
#
#     laravel_setup.sh
#
# Tested with Laravel versions 
# 5.6, 5.7 on Ubuntu 18.04
#----------------------------------------#
# 
# usage:
# ./laravel_setup.sh laravel_path action 
#
# Author: Marko Pantelic
#----------------------------------------#


# TODO:
# - Add getopts() logic and options
#	option -e='.env file path'
# - Create check if path contains non-allowable path string characters (!@&| etc.)


PROG_NAME='larvel_setup';

INSTALL=0;
SETUP=0; # flag to encompass all actions except install
MYSQL_STRING_MAX_HACK=0;
SET_PERMISSIONS=0;

LARAVEL_VERSION=''; # e.g. '~5.6' or ':5.6.0'



# CHECK SCRIPT REQUIRED ARGUMENTS
if [ $# -eq 0 ]; then
	echo "usage:\n$0 laravel_path action";
	echo "actions: install, setup"; # add later set_permissions, mysql_string_hack
	exit 1;
elif [ $# -lt 2 ]; then
	echo "$PROG_NAME: script requires two arguments (arg1 laravel_path, arg2 action):";
	echo "$PROG_NAME: Example:";
	echo "$PROG_NAME: ~/NetBeansProject/laravel-proj setup";
	exit 1;
fi

# TODO: here create check if path contains non-allowable path string characters (!@&| etc.)
PROJECT_PATH=${1%/}; # remove possible trailing forward-slash in the argument 'path'!
ACTION=$2;

if [ "$PROJECT_PATH" == '' ]; then
	echo "$PROG_NAME: invalid laravel path specified. Path cannot be an empty string.";
	exit 1;
fi



# SET FLAGS ACCORDING TO ACTION INSTRUCTED
case "$ACTION" in

	install) echo "$PROG_NAME: installing";
		INSTALL=1;
		SETUP=1;
		;;
	setup) echo "$PROG_NAME: setting up";
		SETUP=1;
		;;
	*) echo "$PROG_NAME: invalid action specified";
		exit 1;
		;;
esac


# IF $SETUP IS SET, ENABLE OTHER SETUP ACTIONS
if [ $SETUP -eq 1 ]; then
	MYSQL_STRING_MAX_HACK=1;
	SET_PERMISSIONS=1;
fi




if [ $INSTALL -eq 1 ]; then

	# check if folder with Laravel installation already exists
	if [ -d "$PROJECT_PATH" ]; then 
		echo "$PROG_NAME: Folder already exists on path '$PROJECT_PATH'. Cannot install.";
		# TODO: here create check if that folder contains Laravel's folders (e.g. app resources database etc.)
		exit 1;
	else 

		# check if composer is installed and set to be found $PATH
		which php
		if [ $? -ne 0 ]; then
			echo "$PROG_NAME: cannot install Laravel. 'PHP' on execution path is missing";
			exit 1;
		fi

		# check if PHP is installed and set to be found in $PATH
		which composer
		if [ $? -ne 0 ]; then
			echo "$PROG_NAME: cannot install Laravel. 'composer' on execution path is missing";
			echo "$PROG_NAME: install it as global from https://getcomposer.org/download/";
			exit 1;
		fi

		echo "$PROG_NAME: creating fresh installation of Laravel with composer. Path = '$PROJECT_PATH'";
		composer create-project --prefer-dist "laravel/laravel${LARAVEL_VERSION}" $PROJECT_PATH
		
		if [ $? -ne 0 ]; then
			echo "$PROG_NAME: FAILED installation of Laravel! composer returned error signal";
		fi
	fi
fi # end if [ INSTALL ...


if [ $SETUP -eq 1 ]; then
	# if .env isn't created, this script creates it from .env.example and then calls php artisan key:generate
	if [ ! -f "${PROJECT_PATH}/.env" ]; then
		echo "$PROG_NAME: Laravel environment file not found. Creating '.env'";
		cp ${PROJECT_PATH}/.env.example ${PROJECT_PATH}/.env;

		echo "$PROG_NAME: generating Laravel application key";
		php "${PROJECT_PATH}/artisan" key:generate;
	else
		echo "$PROG_NAME: .env file already present.";
	fi
fi


# resolve supplied path to absolute path with readlink
# NOTE: this call to readlink command is not compatible with OSX and other BSD flavours
LARAVEL_PROJ_DIR=`readlink -e "$PROJECT_PATH"`;


# check if absolute path resolving is valid
if [ "$LARAVEL_PROJ_DIR" == "" ]; then
	echo "$PROG_NAME: ERROR: invalid path resulted after resolving to absolute path with 'readlink' command";
	exit 1;
fi
echo "$PROG_NAME: absolute project path: \"$LARAVEL_PROJ_DIR\"";


# check if given directory path is valid 
# this check is now superfluous when using readlink, because it (readlink) 
# returns empty string when path is invalid)
if [ ! -d "$LARAVEL_PROJ_DIR" ]; then
	echo "$PROG_NAME: invalid supplied directory path";
	exit 1;
fi


if [ $SET_PERMISSIONS -eq 1 ]; then
	echo "$PROG_NAME: setting Laravel's subdirectories permissions";
	chmod -R 777 "$LARAVEL_PROJ_DIR/app" "$LARAVEL_PROJ_DIR/storage" "$LARAVEL_PROJ_DIR/bootstrap/cache";

	if [ $? -eq 0 ]; then
		echo "$PROG_NAME: chmod completed";
	else
		echo "$PROG_NAME: NOTE! couldn't chmod freely. You have inadequate privileges?";
		echo "$PROG_NAME: ending script.";
		exit 1;
	fi
fi


if [ $MYSQL_STRING_MAX_HACK -eq 1 ]; then
	# MYSQL/MariaDB string type max 191 edit
	sed -i -n '1h;1!H;${
		g;
		s/public function boot()\n\s\s\s\s{/public function boot()\n    {\n        \/\/Hack for MariaDB\/Mysql string type size (line inserted by laravel_startup.sh script)\n        \\Illuminate\\Support\\Facades\\Schema::defaultStringLength(191);/g;p;
		}
		' "$LARAVEL_PROJ_DIR/app/Providers/AppServiceProvider.php"
fi


echo "$PROG_NAME: script successful completion.";
exit 0;
