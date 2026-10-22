#!/bin/bash

### job scheduler block ##

# total energy convergence with respect to no. k-points;
# grep total (free) energy and energy per atom from OUTCAR
# kpoints vs energy written in energy_kpoints.txt

rm -f energy_kpoints1.txt

for ((k=1 ; k<=12 ; k++))	# loops through dim. of k mesh in each direction from min (e.g. 1) and max (e.g. 12) in steps of 1
do
  cat > KPOINTS << EOF	# rewriting KPOINTS file each time with new k value
  Pristine Cubic CsPbI3 unit cell
    0           

  Monkhorst Pack  
    $k $k $k       
    0 0 0        
EOF

  # change srun accordingly to match the job scheduler syntax
  srun -N $SLURM_JOB_NUM_NODES -n $SLURM_NTASKS -c $OMP_NUM_THREADS -m block:block:block $VASP > vasp.out


  e=`grep "free  energy" OUTCAR | awk '{print $5}'`	# finds final line containing free energy (note the double space) of system, prints the actual number
  echo $k $e >> energy_kpoints1.txt
done