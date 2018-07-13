#!/bin/bash

## Creates an xml-file which can be used as a slideshow desktop background on various gnome-based desktop enviroments
## Tested with MATE and Gnome2
## USAGE:
##   bslides [--time <time>] [--transition <time>] [--output <file>] ImageFiles ...

isNumber () {
# @param: $1
# Checks if $1 is a number
# @return 1 if $1 is a valid number, 0 otherwise

	if [[ $1 =~ ^([0-9](\.)?)+$ ]] ; then
		return 1
	else
		return 0
	fi
}

printUsage () {
# Prints Usage with all Options (like a manpage)

	echo "USAGE: "
	echo -e -n "  bslides [--time \e[4mTIME IN SECONDS\e[0m] "
 	  echo -e -n "[--transition \e[4mTIME IN SECONDS\e[0m] "
 	  echo -e    "[--output \e[4mFILE\e[0m] ImageFiles ..."
	echo "   If --time is omitted 1650.0 is used as the default value"
	echo "   If --transition is omitted 5.0 is used as the default value"
	echo "   If --output is omitted, xml will be written to './backgrounds.xml'"
}

###################  BEGIN SCRIPT  ###################

#Standardeinstellungen
TIME="1650.0"
TDUR="5.0"
OUTP="backgrounds.xml"

HEADER="<background>
	<starttime>
	<year>2018</year>
	<month>01</month>
	<day>01</day>
	<hour>00</hour>
	<minute>00</minute>
	<second>00</second>
	</starttime>
	<!-- This animation will start at midnight. -->"
STATIC="	<static>
		<duration>%DUR</duration>
		<file>%FILE</file>
	</static>"
TRANSITION="	<transition>
		<duration>%DUR</duration>
		<from>%F1</from>
		<to>%F2</to>
	</transition>"
FOOTER="</background>"

# Get Parameters
fcount=0
while [ "$1" != '' ] ; do
	if [ "$1" == '--time' ] ; then
		shift
		isNumber $1
		if [[ $? != 0 ]] ; then
			TIME=$1
		else
			echo "--time requieres a number; '$1' is not a valid number !"
			printUsage
			exit
		fi
	elif [ "$1" == '--transition' ] ; then
		shift
		isNumber $1
		if [[ $? != 0 ]] ; then
			TDUR=$1
		else
			echo "--transition requieres a number; '$1' is not a valid number !"
			printUsage
			exit
		fi
	elif [ "$1" == '--output' ] ; then
		shift
		# Check if not empty
		if [[ $1 =~ ^.+ ]] ; then
			OUTP=$1
		else
			echo "No output file given"
			printUsage
		fi
	else
		images[fcount]="$1" && ((fcount++))
	fi
	shift
done

if [[ $fcount == 0 ]] ; then
	echo "No Image Files passed !"
	printUsage
	exit
fi



#Write XML
echo "$HEADER" > "$OUTP"
for ((j=0;j<fcount;j++))
 do
	s=${STATIC//%DUR/$TIME}
	s=${s//%FILE/${images[j]}}
	echo "$s" >> "$OUTP" 
	
	s=${TRANSITION//%DUR/$TDUR}
	s=${s//%F1/${images[j]}}
	if (( $j+1 < $fcount )) ; then
		s=${s//%F2/${images[j+1]}}
	else
		s=${s//%F2/${images[0]}}
	fi
	echo "$s" >> "$OUTP" 
 done
echo "$FOOTER" >> "$OUTP"



