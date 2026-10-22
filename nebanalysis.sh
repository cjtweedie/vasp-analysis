#!/bin/bash

# create empty output files
rm force_conv.txt
rm energy_conv.txt
touch force_conv.txt
touch energy_conv.txt

# /path/to/inputs
# change this to match your directory structure
dir_in=$(pwd)

# find total no. steps to write to files later
Nstep=`grep -B 2 "accuracy" $dir_in/vasp.out | head -n 1 | awk '{print $1}'`

# need to grep magnitude of total forces for all images in a NEB calculation
# so can track when max forces have reached given tol for all images
# e.g. actual convergence criteria may be 0.01eV/A, but want to check when forces reached 0.03 without redoing
N=300
Ftol1=0.03
Ftol2=0.02
Ftol3=0.01
printf "%s %s %s\n" "Force tol (eV/A)" "Step no." "Max NEB force" >> force_conv.txt
awk -v Ftol="$Ftol1" '$2<Ftol {
	printf "%s\n%.2f%s %i %.5f\n", "img01", Ftol, ":", $1, $2 >> "force_conv.txt"; exit
}' $dir_in/01/fe.dat
awk -v Ftol="$Ftol2" '$2<Ftol {
	printf "%.2f%s %i %.5f\n", Ftol, ":", $1, $2 >> "force_conv.txt"; exit
}' $dir_in/01/fe.dat
awk -v Ftol="$Ftol3" '$2<Ftol {
	printf "%.2f%s %i %.5f\n", Ftol, ":", $1, $2 >> "force_conv.txt"; exit
}' $dir_in/01/fe.dat
awk -v Ftol="$Ftol1" '$2<Ftol {
	printf "\n%s\n%.2f%s %i %.5f\n", "img02", Ftol, ":", $1, $2 >> "force_conv.txt"; exit
}' $dir_in/02/fe.dat
awk -v Ftol="$Ftol2" '$2<Ftol {
	printf "%.2f%s %i %.5f\n", Ftol, ":", $1, $2 >> "force_conv.txt"; exit
}' $dir_in/02/fe.dat
awk -v Ftol="$Ftol3" '$2<Ftol {
	printf "%.2f%s %i %.5f\n", Ftol, ":", $1, $2 >> "force_conv.txt"; exit
}' $dir_in/02/fe.dat
awk -v Ftol="$Ftol1" '$2<Ftol {
	printf "\n%s\n%.2f%s %i %.5f\n", "img03", Ftol, ":", $1, $2 >> "force_conv.txt"; exit
}' $dir_in/03/fe.dat
awk -v Ftol="$Ftol2" '$2<Ftol {
	printf "%.2f%s %i %.5f\n", Ftol, ":", $1, $2 >> "force_conv.txt"; exit
}' $dir_in/03/fe.dat
awk -v Ftol="$Ftol3" '$2<Ftol {
	printf "%.2f%s %i %.5f\n", Ftol, ":", $1, $2 >> "force_conv.txt"; exit
}' $dir_in/03/fe.dat

# check for energy convergence as well
# find step no where saddle image energy reaches given tolerance wrt final energy barrier
Ea=`grep -i " 2 " $dir_in/nebef.dat | awk '{print $3}'`
Etol1=0.05
Etol2=0.025
Etol3=0.01
Etol4=0.001
printf "%s %s %s\n" "Energy tol (eV)" "Step no." "Saddle energy" >> energy_conv.txt
awk -v Ea="$Ea" -v Etol="$Etol1" '(($3-Ea))<Etol {
	printf "%.3f%s %i %.5f\n", Etol, ":", $1, $3 >> "energy_conv.txt"; exit
}' $dir_in/02/fe.dat
awk -v Ea="$Ea" -v Etol="$Etol2" '(($3-Ea))<Etol {
	printf "%.3f%s %i %.5f\n", Etol, ":", $1, $3 >> "energy_conv.txt"; exit
}' $dir_in/02/fe.dat
awk -v Ea="$Ea" -v Etol="$Etol3" '(($3-Ea))<Etol {
	printf "%.3f%s %i %.5f\n", Etol, ":", $1, $3 >> "energy_conv.txt"; exit
}' $dir_in/02/fe.dat
awk -v Ea="$Ea" -v Etol="$Etol4" '(($3-Ea))<Etol {
	printf "%.3f%s %i %.5f\n", Etol, ":", $1, $3 >> "energy_conv.txt"; exit
}' $dir_in/02/fe.dat


# different way of checking energy convergence: gradient over last d steps
# since MLIP-initialised NEBs usually converge F within 50 steps, I'll take d=10 (~20%)
d=10
dE_sum=0
printf "\n%s %i %s\n" "Energy change per step (meV) over last" $d "steps" >> energy_conv.txt
for ((j=$((Nstep-d)) ; j<=$Nstep-1 ; j++))
do
	k=$((Nstep-j+1))
	E_b=`grep "0 " $dir_in/02/fe.dat | tail -n $((k+1)) | head -n 1 | awk '{print $3}'`
	E_f=`grep "0 " $dir_in/02/fe.dat | tail -n $((k-1)) | head -n 1 | awk '{print $3}'`
	dE=`echo "1000*0.5*$E_f - 1000*0.5*$E_b" | bc`
	dE_sum=`echo "$dE_sum + $dE" | bc`
	printf "%i %0.8f\n" $j $dE >> energy_conv.txt
done

#awk -v d="$d" -v dE_sum="$dE_sum" '{
#}' $dir_in/02/fe.dat

# print average
d_inv=`echo "1.0/$d.0" | bc -l`
dE_avg=`echo "$d_inv*$dE_sum" | bc`
printf "\n%s %0.5f\n" "Avg gradient (meV) =" $dE_avg >> energy_conv.txt

# write total no. steps in both files just for reference
# maybe fix so writes to both in just one grep call
printf "\n%s %i\n" "Total steps:" $Nstep >> force_conv.txt
printf "\n%s %i\n" "Total steps:" $Nstep >> energy_conv.txt