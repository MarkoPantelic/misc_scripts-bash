#!/bin/bash

#============================================#
#		REPLACE STRING		     #
#					     #
# Script to replace stringA with stringB in  #
# one file or files in specified directory   #
#--------------------------------------------#
# author: Marko Pantelic                     #
#============================================#


prog_name="replace_string"
filename="testreplace.txt"
oldstr=$1
newstr=$2
ford=$3
target=$4
mode=$5


function print_usage(){
	echo -e "Usage: $prog_name stringA stringB [fd] target [mode]"
	echo -e "\targ(3) 'f' - target is file"
	echo -e "\targ(3) 'd' - target is a directory"
	echo -e "\targ(5) 'test' - print lines which will be affected"
}


if [[ $# -lt 4 ]]; then
	print_usage
	exit 1
fi


if [[ "$ford" == "d" ]]; then

	dir=$target

	if [[ ! -d $dir ]]; then
		echo "$prog_name: $dir is not a directory"
		exit 1
	fi

	all_files=`ls $target`
	question="replace '$oldstr' with '$newstr' in all files in directory '$dir'? (y/n)"

elif [[ "$ford" == "f" ]]; then

	if [[ ! -f $target ]]; then
		echo "$prog_name: unknown filename '$target'"
		exit 1
	fi
		
	dir="."
	all_files="$target"
	question="replace '$oldstr' with '$newstr' in file '$target'? (y/n)"

else 
	echo "$prog_name: invalid third argument '$ford', allowed only 'd' or 'f'"
	exit 1
fi



if [[ $mode != "test" ]]; then

	while [[ $answer != y ]]
	do 
		echo "$prog_name: $question"
		read answer rest

		if [[ $answer == n ]]; then
			exit 1;
		fi
	done
fi


for file in $all_files
do
	if [[ -r "$dir/$file" && -f "$dir/$file" ]]; then
		
		if [[ $mode == "test" ]]; then
			echo -e "\n$file:"
			cat "$dir/$file" | sed -n "/\b$oldstr\b/p" 
		else
			# NOTE: sed \b -> word boundary ( boundary chars among others are ')', '(', '*' )
			sed -i "s/\b$oldstr\b/$newstr/g" "$dir/$file"
			echo "done... $file"
		fi
	else
		if [[ ! -d "$dir/$file" ]]; then
			echo "$prog_name: skipping file '$file' - not readable or some other error"
		fi
	fi
done





