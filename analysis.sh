#!/bin/bash

# !!! MAY WANT TO GENERALISE IN FUTURE TO RUN SCRIPTS FROM ANY DIRECTORY W/O COPY+PASTING
# USE CLI TO SPECIFY INPUT FOLDER !!!

# /path/to/inputs and /path/to/outputs
# change this to match your directory structure
dir_in=./test_data
dir_out=./test_outputs

# create empty output files
rm $dir_out/relax_energy.txt
touch relax_energy.txt
rm $dir_out/relax_force.txt
touch relax_force.txt
rm $dir_out/relax_energy_diff.txt
touch relax_energy_diff.txt

# get no. ions by difference between first/last line in total force list
# !!! FIX THIS UP TO JUST READ NIONS LINE !!!
first=`grep -A 2 -n "POSITION" $dir_in/OUTCAR | tail -n +3 | head -n 1 | awk -F: '{printf "%i", $1}'`
last=`grep -B 2 -n "total drift:" $dir_in/OUTCAR | head -n 1 | awk -F: '{printf "%i", $1}'`
Nion=$((last-first+1))

# grep no. ionic steps for plotting
Nstep=`grep "Ionic step" $dir_in/OUTCAR | tail -n 1 | awk '{printf "%i", $4}'`


# for loop to get data at each ionic step
# grep total energy at end of each ionic step
# double space ensures it doesn't get values at each elec step
printf "%s	%s\n" "Step no." "Total energy (eV)" >> relax_energy.txt
for ((j=1; j<=$Nstep; j++))
do
	k=$((Nstep-j+1))
	energy=`grep "free  energy" $dir_in/OUTCAR | tail -n $k | head -n 1 | awk '{print $5}'`
	printf "%i	%.6f\n" $j $energy >> relax_energy.txt
done


# also grep energy from last X steps to estimate rate of change in final leg of optimisation
# use e.g. 20 steps, central difference derivative for each step (c=(f-b)/2)
d=20
dE_sum=0
printf "%s	%s\n" "Step no." "Change in energy (meV)" >> relax_energy_diff.txt
for ((j=$((Nstep-d)); j<=$Nstep-1; j++))
do
	k=$((Nstep-j+1))
	E_b=`grep "free  energy" $dir_in/OUTCAR | tail -n $((k+1)) | head -n 1 | awk '{print $5}'`
	E_f=`grep "free  energy" $dir_in/OUTCAR | tail -n $((k-1)) | head -n 1 | awk '{print $5}'`
	#dE=`echo "1000*0.5*$E_f - 1000*0.5*$E_b" | bc`
	dE=$(awk -v E_f="$E_f" -v E_b="$E_b" 'BEGIN {printf "%.10f\n", 1000*(0.5*E_f - 0.5*E_b)}')
	#dE_sum=`echo "$dE_sum + $dE" | bc`
	dE_sum=$(awk -v dE_sum="$dE_sum" -v dE="$dE" 'BEGIN {printf "%.10f\n", dE_sum + dE}')
	#echo $j $dE >> relax_energy_diff.txt
	printf "%i	%.3f\n" $j $dE >> relax_energy_diff.txt
done

# print average
#d_inv=`echo "1.0/$d.0" | bc -l`
d_inv=$(awk -v d="$d" 'BEGIN {printf "%.10f\n", 1/d}')
#dE_avg=`echo "$d_inv*$dE_sum" | bc`
dE_avg=$(awk -v d_inv="$d_inv" -v dE_sum="$dE_sum" 'BEGIN {printf "%.10f\n", d_inv*dE_sum}')
printf "\n%s %i %s	%.3f\n" "Avg gradient over last" $d "steps (meV):" $dE_avg >> relax_energy_diff.txt


# find ion which experiences maximum force compared to all others, at each step
# grep magnitude of the force Ftot=sqrt(Fx^2+Fy^2+Fz^2)
count=0
printf "%s	%s\n" "Step no." "Max force (eV/Å)" >> relax_force.txt
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
	printf "%i	%.6f\n", count, max >> "relax_force.txt"
}' $dir_in/OUTCAR

# plotting energy & forces as functions of relaxation step no.
gnuplot converge_plot.gnu

mv relax_energy.txt ./test_outputs
mv relax_force.txt ./test_outputs
mv relax_energy_diff.txt ./test_outputs
mv fe_convergence.png ./test_outputs