#!/bin/bash

# /path/to/inputs and /path/to/outputs
# change this to match your directory structure
dir_in=./test_data
dir_out=./test_outputs

# create empty output files
rm relax_energy.txt
touch relax_energy.txt
rm relax_force.txt
touch relax_force.txt
rm relax_energy_diff.txt
touch relax_energy_diff.txt

# get no. ions by difference between first/last line in total force list
first=`grep -A 2 -n "POSITION" $dir_in/OUTCAR | tail -n +3 | head -n 1 | awk -F: '{printf "%i", $1}'`
last=`grep -B 2 -n "total drift:" $dir_in/OUTCAR | head -n 1 | awk -F: '{printf "%i", $1}'`
Nion=$((last-first+1))

# grep no. ionic steps for plotting
Nstep=`grep "Ionic step" $dir_in/OUTCAR | tail -n 1 | awk '{printf "%i", $4}'`


# for loop to get data at each ionic step
# grep total energy at end of each ionic step
# double space ensures it doesn't grab values at each elec step
for ((j=1; j<=$Nstep; j++))
do
	k=$((Nstep-j+1))
	energy=`grep "free  energy" $dir_in/OUTCAR | tail -n $k | head -n 1 | awk '{print $5}'`
	echo $j $energy >> relax_energy.txt
done


# also grep energy from last X steps to estimate rate of change in final leg of optimisation
# use e.g. 20 steps, central difference derivative for each step (c=(f-b)/2)
d=20
dE_sum=0
for ((j=$((Nstep-d)); j<=$Nstep-1; j++))
do
	k=$((Nstep-j+1))
	E_b=`grep "free  energy" $dir_in/OUTCAR | tail -n $((k+1)) | head -n 1 | awk '{print $5}'`
	E_f=`grep "free  energy" $dir_in/OUTCAR | tail -n $((k-1)) | head -n 1 | awk '{print $5}'`
	dE=`echo "1000*0.5*$E_f - 1000*0.5*$E_b" | bc`
	dE_sum=`echo "$dE_sum + $dE" | bc`
	echo $j $dE >> relax_energy_diff.txt
done

# print average
d_inv=`echo "1.0/$d.0" | bc -l`
dE_avg=`echo "$d_inv*$dE_sum" | bc`
printf "\n%s %i %s %0.8f" "Avg gradient over last" $d "steps (meV):" $dE_avg >> relax_energy_diff.txt


# find ion which experiences maximum force compared to all others, at each step
# grep magnitude of the force Ftot=sqrt(Fx^2+Fy^2+Fz^2)
count=0
awk -v Nion="$Nion" -v count="$count" '/TOTAL-FORCE/ {
	count++
	max = 0.0
	getline
	for(j=0; j<Nion; j++) {
		getline
		Ftot = sqrt($4^2+$5^2+$6^2)
		if (Ftot > max)
			max = Ftot
	}
	printf "%i %.5f\n", count, max >> "relax_force.txt"
}' $dir_in/OUTCAR

# plotting energy & forces as functions of relaxation step no.
rm fe_convergence.png
gnuplot $dir_scripts/converge_plot.gnu