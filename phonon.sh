#!/bin/bash

# need to adjust N for no. atoms; could just grep this from POSCAR or displace.yaml
# loop to create all 6N displaced POSCAR folders, run static VASP calc for each
# phonopy can then extract forces & force constants from the vasprun.xml in each folder
N=955
for ((i=1 ; i<$N ; i++));     
do
	printf -v j "%03d" "$i"
	mkdir disp"$j"
	cp INCAR KPOINTS POTCAR vasp_setonix.sh ./disp"$j"/
	mv POSCAR-"$j" ./disp"$j"/
	cd ./disp$j
	mv POSCAR-$j POSCAR
	sed -i "s/#SBATCH --job.*/#SBATCH --job-name=disp$j/" vasp_setonix.sh
	sbatch vasp_setonix.sh
	cd ..
done