#!/bin/bash

# ================================= #
# Start and control docker projects #
# ================================= #

# TODO: usermod <- goto docker dir and then perform docker-usermod.sh

icommand=$1;
action=$2;

declare -A all_projects;
declare -a chosen_project_arr;
declare -a all_actions;

all_actions=('goto' 'start' 'stop' 'console');
ORIG_IFS=$IFS;
IFS=',' 
eval 'all_actions_string="${all_actions[*]}"';
IFS=$ORIG_IFS;

# TODO make spaces between ','
function print_usage()
{
	echo "commands: 'all'"; echo "actions: "$all_actions_string;
}

# arrays with projects data 
# arr=('abs_path_to_project_dir' 'relative_path_to_docker_dir_from_proj_dir'
proj_youbox=('/var/www/youbox/' 'docker-compose-project-php7');
proj_kms=('/var/www/KMS/' 'docker');
proj_laravel_skeleton=('/var/www/laravel-skeleton-basic/' 'docker');
proj_autoerp=('/var/www/autoerp/' 'docker');

# associative array pointing to arrays with projects data
all_projects=(['youbox']=${proj_youbox[@]} ['kms']=${proj_kms[@]} ['laravel-skeleton']=${proj_laravel_skeleton[@]} ['autoerp']=${proj_autoerp[@]});

# show all projects if 'icommand' == 'all'
if [ "$icommand" == "all" ]; then
	for project_name in "${!all_projects[@]}"; do
		echo -n "$project_name ";	
	done
	echo ""; # newline
	exit 0;
else 
	project=$icommand;
fi

# normalize input 'project' string (convert to lowercase)
project="`echo $project | tr '[:upper:]' '[:lower:]'`";	

# loop through all projects array and see if any does match
for key in "${!all_projects[@]}"; do
	if [ "$project" == "$key" ]; then
		chosen_project=$key;	
		break;
	fi
done

if [ -z $chosen_project ]; then
	echo "Invalid project name";
	# TODO: print all supported project names
	exit 1
fi

chosen_project_arr=( ${all_projects[$chosen_project]} );

project_dir=${chosen_project_arr[0]};
docker_dir=$project_dir${chosen_project_arr[1]};
docker_project_start=$docker_dir/docker-start.sh;
docker_project_stop=$docker_dir/docker-stop.sh;
docker_project_console=$docker_dir/docker-console.sh;

if [ -z $action ]; then
	echo "No argument specified";
	print_usage;
elif [ "$action" == 'goto' ]; then
	echo -n "cd ";
	cat -v <<< $project_dir;
	cd "${project_dir}";	
	exec bash;
elif [[ " ${all_actions[@]} " =~ " ${action} " ]]; then
	cmd=$docker_dir/docker-$action.sh
	( $cmd );
else
	echo "Invalid argument specified";
fi
