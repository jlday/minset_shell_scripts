#!/bin/bash

# This script will take a set of trace files and 
# reduce them by the starting base file
#
# meant to be run against the directory as files 
# are traced so that when the trace is done, all
# traces are reduced and ready for the min set
# calculations 
#
# built for Ubuntu Linux

usage="bash reduce.sh [sourceDir] [outputDir] [continue? 1|0]"

if [ ! -d "$1" ]; then
	echo "Please provide a source directory"
	echo "$usage"
	exit
fi

if [ ! -n "$2" ]; then
	echo "Please provide an output directory"
	echo "$usage"
	exit
fi

if [ ! -d "$2" ]; then
	mkdir "$2"
	if [ ! -d "$2" ]; then
		echo "Please provide an output directory"
		echo "$usage"
		exit
	fi
fi

if [ ! -n "$3" ]; then
	echo "Please provide a 0 (for don't repeat) or 1 (for repeat)"
	echo "$usage"
	exit
fi 

if [ ! $3 -eq 0 ]; then
	if [ ! $3 -eq 1 ]; then
		echo "Please provide a 0 (for don't repeat) or 1 (for repeat)"
		echo "$usage"
		exit
	fi
fi
 
base="base.txt"
IFS=$'
'

if [ ! -f "$1/$base" ]; then
	echo "Please make sure that there is a base file (base.txt) in the"
	echo "source directory"
	echo "$usage"
	exit
fi

cat "$1/$base" | cut -f1-2 | sort > "$2/temp.txt"
mv "$2/temp.txt" "$2/$base"

while [ ! ]
do
	fileList=`ls -s $1 | grep "^ *[1-9]" | grep -v "^ *[0-9]* $base" | sort -r -n -k 1,1 | sed -e 's/^[ \t]*//' | sed -e 's/^[0-9]* //'`
	sleep 10s # let any files that are being written finish
	
	total=`ls -s $1 | grep "^ *[1-9]" | grep -v "^ *[0-9]* $base" | wc -l | awk '{print $1}'`
	count=1

	for file in $fileList
	do
		if [ ! -f "$2/$file" ]; then
			
			echo "Processing $file [$count of $total]"
			
			cat "$1/$file" | cut -f1-2 | sort > "$2/temp.txt"
			mv "$2/temp.txt" "$2/$file"
			
			comm -13 "$2/$base" "$2/$file" > "$2/temp.txt"
			mv "$2/temp.txt" "$2/$file"
		fi
		count=`expr "$count" + 1`
	done
	
	echo "Finished pass..."
	if [ $3 -eq 0 ]; then
		exit
	fi 
done	
