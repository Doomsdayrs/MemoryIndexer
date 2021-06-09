#!/bin/bash
# This script will run through all the physical addresses of a device to figure out restricted regions
# Created by: Doomsdayrs
# June 06 2021 : Inital creation
# June 08 2021 : Modified to 4k increment and overwrite of directory

index=0
INCREMENT=0xfa0
OUTPUT_FILE=output
FAILED=failed-indencies

function intAsHex() {
	printf '%x\n' $1
}
index=`intAsHex 0`

if [ -f "$OUTPUT_FILE" ]; then
	# Read from the old output
	index=`cat $OUTPUT_FILE`

	# Increment to place into failure file
	((index+=INCREMENT))

	echo "Placing failed index in failure file"
	hexIndex=`intAsHex $index`
	echo "0x$hexIndex" >> $FAILED # output hex

	# Increment again, then wait a second before starting again
	((index+=INCREMENT))
	echo "Resuming from old index ($index) + ($INCREMENT x 2)"
	sleep 1
fi

while [ true ]; do
	if 	[ $(($index)) -ge $((0x1000)) 	-a $(($index)) -le $((0xf5b00000))	] || 
		[ $(($index)) -ge $((0x200000)) -a $(($index)) -le $((0x200000)) 	] || 
		[ $(($index)) -ge $((0x2000))	-a $(($index)) -le $((0xf5d01000))	] || 
		[ $(($index)) -ge $((0x200000))	-a $(($index)) -le $((0x88f00000))	] ||
		[ $(($index)) -ge $((0x400000)) -a $(($index)) -le $((0xac300000))	]; then
		echo "Skipping reserved index..."
		sleep 1
	else
		sudo busybox devmem "0x$index"
		echo "0x$index" > $OUTPUT_FILE
	fi
	index=$(("0x$index"+"0x$INCREMENT"))
	index=`intAsHex $index`
done

echo "Finished"
