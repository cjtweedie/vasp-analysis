# vasp-analysis
Scripts for the analysis and post-processing of VASP calculations, in shell, for convenience.
Some python scripts added to interface with py4vasp package, for powerful parsing of hdf5 output and more plotting flexibility than gnuplot affords. Interfaces with pyprocar package for some more niche functionality and PROCAR parsing.

Primarily tracks and plots convergence of ionic relaxations with respect to atomic forces and total energies. 
Can also post-process band structure and DOS calculations, including parsing of data, creation of data structures, atom/orbital projections, and band unfolding.
