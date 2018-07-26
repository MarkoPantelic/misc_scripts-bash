#!/bin/bash

#++++++++++++++++++++++++++++++++++++++++++++++++++++++#
#               raspi_music_play.sh                    #
# Play mp3 music within a folder as if from a playlist #
#++++++++++++++++++++++++++++++++++++++++++++++++++++++#
#  Only for Raspberry Pi computers since omxplayer is  #
#           available only on Raspberry Pi             # 
#------------------------------------------------------#


IFS='
'
cwd=$(pwd)
i=0

beginn=$2
volume=$1
echo "beginn var => $beginn, $volume\n"

if [[ -z $volume ]]; then
	volume="-0"
fi

for song in $(ls $cwd); do
	(( i++ ))

	if [[ -n $beginn ]] && (( i < $beginn)); then
		continue
	fi

	if [[ "$song" = *.mp3 ]] || [[ "$song" = *.MP3 ]] || [[ "$song" = *.flac ]] || [[ "$song" = *.FLAC ]]
		then
			echo "playing $song" && $(omxplayer --vol $volume $song > /dev/null)
	fi

done


echo "\n...goodbye...\n"

