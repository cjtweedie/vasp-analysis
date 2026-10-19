#!/bin/bash

### job scheduler block ##

# loop through ENCUT values within INCAR
# grep total (free) energy and energy per atom from OUTCAR
# ENCUT vs energy written in energy_encut.txt
rm -f energy_encut1.txt

for ((encut = 300 ; encut < 1000 ; encut+=10));     # loops through ENCUT values from min (e.g. 300eV) and max (e.g. 800eV) in steps of x (1,10,50)
do
    sed -i "s/ENCUT.*/ENCUT = $encut/" INCAR        # replaces ENCUT in INCAR with value of "encut" in current loop iteration

    # change srun accordingly to match the job scheduler syntax
    srun -N $SLURM_JOB_NUM_NODES -n $SLURM_NTASKS -c $OMP_NUM_THREADS -m block:block:block $VASP > vasp.out     # runs VASP as normal
    
    e1=`grep "free  energy" OUTCAR | awk '{print $5}'`      # finds final line containing free energy (note the double space) of system, prints the actual number 
    e2=`grep "EATOM" OUTCAR | tail -1 | awk '{printf "%.8f", -$5}'`     # finds every line containing energy/atom, looks at only last one, prints the number with 8 decimal places
    echo $encut $e1 $e2 >> energy_encut1.txt        # creates energy_encut txt file, prints ENCUT, F, E/atom in 3 columns separated by spaces
done