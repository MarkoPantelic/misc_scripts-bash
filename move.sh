#!/bin/bash

#--------------------------------------------
# Script for moving files according to regex
#--------------------------------------------

#global setup
IFS='
'

# protect script file itself from deleting
PROTECTED=${0:2}

SOURCE_DIR=$1
GOAL_DIR=$2
REGEX=$3


movefiles()
{
	source_dir=$1
	let i=0

	for file in $(ls $source_dir | grep $REGEX)
		do
			if [ -f $file ]; then
				arr[i]=$file; let i++;
			fi
		done

	printf "\nnumber of files = %d\n\n" ${#arr[*]}
	printf "all files:\n${arr[*]}\n"
	printf "\nmove above listed files from $SOURCE_DIR to $GOAL_DIR? (y/n)"

	read answer


	case "$answer" in

		y | Y | yes | YES)

			printf "\nmoving files...\n"

			for file in ${arr[*]}
				do
					if [ "$file" != $PROTECTED ]; then
						$(mv "$SOURCE_DIR/$file" $GOAL_DIR) # !
						printf "file $file moved, "
					fi
				done
			printf "\ndone.\n";;

		n | N | no | NO)
			printf "exiting...\n" && exit 0;;
	esac
	 
}


#check if num of args is valid
if [ "$#" -ne 3 ]; then
	printf "cannot execute: Invalid number of arguments\n"
	printf "\nusage: $PROTECTED [source directory] [goal directory] 
[reg ex]\n"
	exit 0
fi

#check if source directory exists
if [ ! -d $SOURCE_DIR ]; then
	printf "cannot execute: directory '$SOURCE_DIR' does not exist\n"
	exit 0
fi

#check if goal directory exist
if [ ! -d $GOAL_DIR ]; then
	printf "cannot execute: directory '$GOAL_DIR' does not exist\n"
	exit 0
fi



movefiles $SOURCE_DIR
