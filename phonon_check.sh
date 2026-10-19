#!/bin/bash

# loop over all disp folders to check if jobs ran successfully
# search for any sort of "job cancelled" message in slurm.out
printf "%s\n" "checking disp calcs for failures"
N=955
for ((i=1 ; i<$N ; i++));
do
	printf -v j "%03d" "$i"
	cd ./disp$j
	if grep -q CANCELLED slurm.out; then
		printf "%s%i %s\n" disp$j "failed" 
	fi
	cd ..
done

printf "%s" "check done"