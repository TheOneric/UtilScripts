#!/bin/bash

mapfile -t files <<<"$CAJA_SCRIPT_SELECTED_FILE_PATHS"

display_list=""
nl=$'\n'
for i in "${files[@]}"
do
	display_list+="${nl}    ${i}"
done


zenity --question --window-icon="warning" --text="Sind Sie sich sicher, dass die folgenden Dateien geschreddert und verbrannt werden sollen ? ${display_list}"
if [ $? = 0 ]; then

	file_count=${#files[@]}
	p=$((100/file_count))
	c=0
	echo "$p"
	(for i in "${files[@]}"
	 do
		srm -r -z "${i}"
		c=$((c+=p))		
		echo "$c"
	 done;
	sleep 1;
	echo "100"
	) | zenity --progress --auto-close --title="Verbleibende Objekte" --text="Gründliches Reinigen ..."  --percentage=0

else
	exit
fi




