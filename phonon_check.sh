#!/bin/bash

# loop over all disp folders to check if jobs ran successfully
# search for any sort of "job cancelled" message in slurm.out
# !!! ALLOW FOR CLI TO CHANGE NO. DISP FOLDERS EASILY !!!
rm ph_fail.txt
touch ph_fail.txt
printf "%s\n" "checking disp calcs for failures" >> ph_fail.txt
N=954
for ((i=1 ; i<=$N ; i++));
do
	printf -v j "%03d" "$i"
	cd ./disp$j
	if grep -q CANCELLED slurm.out || [ ! -f slurm.out ] ; then
		printf "%s%s %s\n" disp$j " failed" >> ../ph_fail.txt
	fi
	cd ..
done

printf "%s" "check done" >> ph_fail.txt