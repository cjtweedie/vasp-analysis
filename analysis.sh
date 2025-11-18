#!/bin/bash

# /path/to/output_files
# change this to match your directory structure
dir=./test_data

rm relax_energy.txt
touch relax_energy.txt
rm relax_force.txt
touch relax_force.txt

# get no. ions by difference between first/last line in total force list
first=`grep -A 2 -n "POSITION" $dir/OUTCAR | tail -n +3 | head -n 1 | awk -F: '{printf "%i", $1}'`
last=`grep -B 2 -n "total drift:" $dir/OUTCAR | head -n 1 | awk -F: '{printf "%i", $1}'`
Nion=$((last-first+1))

# grep no. ionic steps for plotting
Nstep=`grep "Ionic step" $dir/OUTCAR | tail -n 1 | awk '{printf "%i", $4}'`

# for loop to get data at each ionic step
# grep total energy at end of each ionic step
# double space ensures it doesn't grab values at each elec step
for ((j=1; j<=$Nstep; j++))
do
	k=$((Nstep-j+1))
	energy=`grep "free  energy" $dir/OUTCAR | tail -n $k | head -n 1 | awk '{print $5}'`
	echo $j $energy >> relax_energy.txt
done

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
}' $dir/OUTCAR

# plotting energy & forces as functions of relaxation step no.
gnuplot ./converge_plot.gnu

#gnuplot -e 'set terminal pngcairo; set output "energy_convergence.png"; set xlabel "ionic step no."; plot "relax_energy.txt" title "energy [eV]" with lines'
#gnuplot -e 'set terminal pngcairo; set output "force_convergence.png"; set xlabel "ionic step no."; plot "relax_force.txt" title "force [eV/A]" with lines'