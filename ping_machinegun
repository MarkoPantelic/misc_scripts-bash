#!/bin/bash

#=========================#
#
# *** ping machinegun *** #
#
#  Bash multi-ping script #
#
#=========================#


PING_EXE="fping"
PORT_SCAN_EXE="nmap"
VERBOSE=0
PORT_SCAN=0
ADDR_BASE="192.168.0.1"
SUBNET_MASK="255.255.255.0"
FILE_OUTPUT=""

OS="$(uname -s)"


function print_about(){
	echo -e "Ping machinegun is a BASH script for getting ip ICMP responses from ranges of ip addresses.
It's backend executable is 'fping' if available, otherwise - 'ping'."
}


function print_usage(){

	echo "Usage:  ping_machinegun [a:bhvo:ps:] [option argument]"
	echo ""
	echo -e "\t-b \t about this script"
	echo -e "\t-h \t print usage"
	echo -e "\t-v \t verbose mode"
	echo -e "\t-o \t supply filepath for output to a file"
	echo -e "\t-a \t supply base ip address"
	echo -e "\t-s \t supply subnet mask"
	echo -e "\t-p \t scan ports of found ip addresses"

}


function chk_ping_exe(){
	# check if ping executable exists

	if [ ! $PING_EXE == "fping" ]
		then
			PING_EXE="ping"
			pmecho "switching to 'ping' executable"
			pmecho "machinegun degraded to a pistol"
			return 1
	fi

	#if [ -x /bin/fping ] || [ -x usr/sbin/fping ] ! staro !
	which fping 1>/dev/null;
	if [ $? -eq 0 ]
		then
			PING_EXE="fping"
			return 0
		else
			PING_EXE="ping"
			pmecho "there is no 'fping' executable in /bin/fping ... switched to 
normal ping executable"
			return 1
	fi
}


function chk_port_scan_exe(){
	# check if port scan executable exists
	
	which ${PORT_SCAN_EXE} 1>/dev/null;
	
	if [ $? -eq 0 ]
		then
			return 0
		else
			return 1
	fi
}


function one_ping(){
	addr=$1

	pmecho "pinging $addr"

	if [ $PING_EXE == "fping" ]
		then
			fping -c1 -t100 $addr &> /dev/null
		else  
			case $OS in

				CYGWIN*)
					ping -n 1 $addr > /dev/null;;
				Linux)
					ping -c1 $addr > /dev/null;;
				\?)
					ping -c1 $addr > /dev/null;;
			esac
	fi

	statr=$?

	if [ $statr = 0 ]
		then
			pmecho "-------------------------"
			pmecho "RESPONSE FROM $addr"
			pmecho "-------------------------"
			return 0
		else
			return 1
	fi

	return 1
}


function pmecho(){
	# echo only when $ECHO flag is set

	if [ $VERBOSE -eq 1 ]
		then echo $@	
	fi
}


function calc_range(){
	# calculate bitwise ip range
	# start range bitwise formula: mask & IP,... in bash -> $(($subnet_byte&$ip_byte))  
	# end range bitwise formula: (~mask & 255 ) | (mask & IP),... in bash -> $(((~$subnet_byte&255)|($subnet_byte&$ip_byte)))

	ip_byte=$1
	subnet_byte=$2
	mode=$3

	if [ $mode == 's' ]
		then
			start=$(($subnet_byte&$ip_byte))
			echo "$start"

	elif [ $mode == 'e' ]
		then
			end=$(((~$subnet_byte&255)|($subnet_byte&$ip_byte)))
			echo "$end"
	else
		echo "Error. Invalid argument '$mode' in funciton calc_range()" 
		exit 1
	fi
}


function scan_ports(){
	# scan with nn ports of found ip addresses

	found_addrs="$@"

	echo "passing arguments to nmap: $found_addrs"

	for addr in $@	
	do
		nmap $addr
	done

	return 0;

}


function print_found(){

	echo ""
	echo "ICMP responses received:"
	echo "$@"
	echo Done.
}





# main()


while getopts ":bhvpo:a:s:" opt
do
	case $opt in
		b) print_about; exit;;
		h) print_usage; exit;;
		v) VERBOSE=1;;
		o) echo "o opition for file output not implemented!";;
		a) ADDR_BASE=$OPTARG;;
		s) SUBNET_MASK=$OPTARG;;
		p) PORT_SCAN=1;;
		\?) echo "Invalid option: -$OPTARG" >&2; exit 1;;
		:) echo "Option -$OPTARG requires an argument" >&2; exit 1;;
	esac
done



if [ "$EUID" -ne 0 ]
	then 
		pmecho "NOTE: Process did not start as root"
		PING_EXE="ping"
fi
 

declare -a res_arr

chk_ping_exe



#old method
#addr_base=$(echo $ADDR_BASE | cut -d. -f 1,2,3)

orig_IFS=$IFS

IFS="."
read -r -a ip_byte_array <<< "$ADDR_BASE"
read -r -a subnet_byte_arr <<< "$SUBNET_MASK"

# CHECK IF THERE ARE FOUR ELEMENTS
if [ ${#ip_byte_array[@]} -ne 4 ]
	then echo "invalid -a argument - ip address" >&2
	exit 1;
fi

if [ ${#subnet_byte_arr[@]} -ne 4 ]
	then echo "invalid -s argument - subnet mask" >&2
	exit 1;
fi

# NOT DONE: CHECK IF ELEMENTS ARE NUMBERS AND ARE BETWEEN 0 AND 255 !!!!!!

#for ip_byte in "${ip_byte_array[@]}"
#	do
#		echo $ip_byte
#	done

IFS=$orig_IFS



#calculate a range of ip addresses to ping - calulated from a given ip base address and subnet mask

addr_oct_1_2="${ip_byte_array[0]}.${ip_byte_array[1]}"

ip_byte3=${ip_byte_array[2]}
subnet_byte3=${subnet_byte_arr[2]}

ip_byte4=${ip_byte_array[3]}
subnet_byte4=${subnet_byte_arr[3]}

range_b3_start=$(calc_range $ip_byte3 $subnet_byte3 s)
range_b3_end=$(calc_range $ip_byte3 $subnet_byte3 e)

range_b4_start=$(calc_range $ip_byte4 $subnet_byte4 s)
range_b4_end=$(calc_range $ip_byte4 $subnet_byte4 e)

# +1 because 0 is a loop number, -1 at the end because broadcast address will not be pinged
total_range=$((($range_b3_end+1-$range_b3_start)*($range_b4_end+1-$range_b4_start)-1))
pmecho "number of ip addresses which will be pinged: $total_range"
pmecho "address range from $addr_oct_1_2.$range_b3_start.$range_b4_start to $addr_oct_1_2.$range_b3_end.$range_b4_end" 




# ping all addresses by changing the value of third and fourth octets

for ((i=$range_b3_start; i<=$range_b3_end; i+=1))
do

	addr_oct_3=".$i"
	

	for ((j=$range_b4_start; j<=$range_b4_end; j+=1))
	do

		if [[ $i -eq $range_b3_end && $j -eq $(($j-1)) ]]
			then
				# substract 1 from last byte because it is a broadcast address
				let "broadcast_byte = j - 1"
				addr_oct_4=".$broadcast_byte"
		else
			addr_oct_4=".$j"
		fi

		addr="$addr_oct_1_2$addr_oct_3$addr_oct_4"

		one_ping $addr

		if [ $? -eq 0 ]
			then
				res_arr[$j]=$addr
		fi

		trap 'print_found "${res_arr[@]}"; exit' 2 15

	done

done





# Do port scan if requested.
# In the end, echo results.


if [ $PORT_SCAN -eq 1 ] 
then

	chk_port_scan_exe

	if [ $? -eq 0 ]
	then
		echo "Executing port scan ..."
		scan_ports "${res_arr[@]}"
	else
		echo "Note: An executable for a port scan was not found"
		print_found "${res_arr[@]}"
	fi
else
	print_found "${res_arr[@]}"
fi



exit 0


