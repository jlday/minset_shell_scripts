#!/bin/bash 

# Takes a directory of trace files and calculates a minimum set
# Files are sorted and processed largest to smallest, each file is
# then compared against each other file, with duplicates between
# the two files being removed from the smaller file.  The script
# gets a bit messy because the file list needs to reorder itself
# as it minimizes files, so that the largest file that hasn't been
# processed is always next in line, even though the size is 
# constantly changing with each pass
#
# The result is a set of trace files with the largets trace containing
# the largets unique coverage
#
# For best results, run reduce.sh on the traced files before running 
# this script, this script assumes that files are sorted and reduced.
#
# built for Ubuntu Linux

usage="bash minset.sh [traceDir]"

if [ ! -d "$1" ]; then
	echo "Please provide a valid directory"
	echo "$usage"
	exit
fi

base="base.txt"

fileList=`ls -s $1 | grep "^ *[1-9]" | grep -v "^ *[0-9]* $base" | sort -r -n -k 1,1 | sed -e 's/^[ \t]*//' | sed -e 's/^[0-9]* //'`
compareList=$fileList
total=`ls -s $1 | grep "^ *[1-9]" | grep -v "^ *[0-9]* $base" | wc -l | awk '{print $1}'`

while [ `echo "$fileList" | wc -l` -gt 1 ]
do
	file1=`echo "$fileList" | head -1`	

	echo "Processing $file1 [remaining:$total]" 
	compareList=`echo "$compareList" | grep -v "$file1"`

	for file2 in $compareList
	do
		if [ -f "$1/$file1" ]; then
			if [ -f "$1/$file2" ]; then
				comm -13 "$1/$file1" "$1/$file2" > "$1/temp.txt"
				mv "$1/temp.txt" "$1/$file2"
			else
				echo "$file2"
			fi
		else
			echo "$file1"
		fi
	done
	fileList=`ls -s $1 | grep "^ *[1-9]" | grep -v "^ *[0-9]* $base" | sort -r -n -k 1,1 | sed -e 's/^[ \t]*//' | sed -e 's/^[0-9]* //'`

	file=`echo "$fileList" | head -1`
	while [[ "$compareList" != *"$file"* ]]
	do
		fileList=`echo "$fileList" | grep -v "$file"`
		file=`echo "$fileList" | head -1`
	done
	total=`echo "$fileList" | wc -l`
done

echo "Done."
