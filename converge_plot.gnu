set xlabel "Ionic step no."
set ylabel "Force [eV/Å]"
set y2label "Energy [eV]"
set tics out nomirror
set y2tics out nomirror
set grid
set pointsize 0.8
set key right top
set log y
set terminal pngcairo
set output "fe_convergence.png"

plot "relax_force.txt" u 1:2 axis x1y1 t "Max force" w l lt rgb "#4169e1" lw 1.5, \
     "relax_energy.txt" u 1:2 axis x1y2 t "Energy" w l lt rgb "#ff4500" lw 1.5