import py4vasp
import pyprocar
import numpy as np
import matplotlib.pyplot as plt
import matplotlib._color_data as mcd
import matplotlib.colors as mcol
import matplotlib.ticker as tick
from matplotlib import colormaps

from projected_bands import *

# Cs doesn't contribute anything significant near Fermi level
# also Pb/I/Br s states further down in valence bulk states
# so can leave out if plotting close to E_F
EF_prist_PBE = 1.152003
EF_prist_SCAN = 0.89561653
EF_VI_PBE = 1.108805
EF_VI_SCAN = 0.92635978

# energy plotting ranges, in ref to Fermi level (usually setting as VBM)
Erange_full = [-15, 8]
Erange_half = [-7.5, 7]
Erange_prist_PBE = [0.38-EF_prist_PBE, 3.82-EF_prist_PBE]
Erange_prist_SCAN = [0.08-EF_prist_SCAN, 3.92-EF_prist_SCAN]
Erange_VI_PBE = [0.38-EF_VI_PBE, 3.82-EF_VI_PBE]
Erange_VI_SCAN = [0.1-EF_VI_SCAN, 4.0-EF_VI_SCAN]

# kpath ticks & labels
kticks = [0, 9, 19, 29, 39, 49, 59, 69, 79, 89]
kmag_ticks = kticks
kpath = [r"$\Gamma$", "X", "S", "Y", r"$\Gamma$", "Z", "U", "R", "T", "Z"]

# need to cat colour lists together if >10 orbitals (tableau list size 10 I think)
col = list(mcol.TABLEAU_COLORS) + list(mcol.TABLEAU_COLORS)

prist_PBE_calc = py4vasp.Calculation.from_path("./Pristine_PBE")
prist_PBE_band = prist_PBE_calc.band.read(selection="s(Cs,Pb,I,Br), p(Cs,Pb,I,Br), d(Cs,Pb,I,Br)", fermi_energy=EF_prist_PBE)

prist_PBE_onsite_calc = py4vasp.Calculation.from_path("./Pristine_PBE_onsite")
prist_PBE_onsite_band = prist_PBE_onsite_calc.band.read(selection="Cs,Pb,I,Br", fermi_energy=EF_prist_PBE)

prist_PBE_KOPT_calc = py4vasp.Calculation.from_path("./Pristine_PBE_KOPT")
prist_PBE_KOPT_band = prist_PBE_KOPT_calc.band.read(selection="kpoints_opt(s(Cs,Pb,I,Br)), kpoints_opt(p(Cs,Pb,I,Br)), kpoints_opt(d(Cs,Pb,I,Br))", fermi_energy=EF_prist_PBE)

prist_PBE_KOPT_onsite_calc = py4vasp.Calculation.from_path("./Pristine_PBE_KOPT_onsite")
prist_PBE_KOPT_onsite_band = prist_PBE_KOPT_onsite_calc.band.read(selection="kpoints_opt(Cs,Pb,I,Br)", fermi_energy=EF_prist_PBE)

prist_SCAN_KOPT_calc = py4vasp.Calculation.from_path("./Pristine_r2SCAN_KOPT")
prist_SCAN_KOPT_band = prist_SCAN_KOPT_calc.band.read(selection="kpoints_opt(s(Cs,Pb,I,Br)), kpoints_opt(p(Cs,Pb,I,Br)), kpoints_opt(d(Cs,Pb,I,Br))", fermi_energy=EF_prist_SCAN)

# this is just like PBE explicit kpoint list, but includes the symmetry-weighted regular mesh kpoints BEFORE the zero-weighted line of kpoints
# in this case, only want to access bands over the array excluding first 4 kpoints
prist_SCAN_KEXP_calc = py4vasp.Calculation.from_path("./Pristine_r2SCAN_KEXP")
prist_SCAN_KEXP_band = prist_SCAN_KEXP_calc.band.read(selection="s(Cs,Pb,I,Br), p(Cs,Pb,I,Br), d(Cs,Pb,I,Br)", fermi_energy=EF_prist_SCAN)

#for k in prist_SCAN_KEXP_band.keys():
#    print(k)
print(len(prist_SCAN_KEXP_band["kpoint_distances"]))
print(prist_SCAN_KEXP_band["kpoint_distances"])

# find differences in projection weights calculted by PBE vs SCAN functionals
# if consistent with info in PROCAR then not just a VASP write/parse issue
#print("Total proj. onto I_p from highest occ. band at Gamma (PBE): ", prist_PBE_band["I_p"][0,544-1])
#print("Total proj. onto I_p from highest occ. band at Gamma (PBE, KPOINTS_OPT): ", prist_PBE_KOPT_band["I_p"][0,544-1])
#print("Total proj. onto I_p from highest occ. band at Gamma (r2SCAN, KPOINTS_OPT): ", prist_SCAN_KOPT_band["I_p"][0,544-1])
#print("Total proj. onto I_p from highest occ. band at Gamma (r2SCAN, KPOINTS_EXP): ", prist_SCAN_KEXP_band["I_p"][4,544-1], "\n")
#print("Total proj. onto Br_p from highest occ. band at G (PBE): ", prist_PBE_band["Br_p"][0,544-1])
#print("Total proj. onto Br_p from highest occ. band at G (r2SCAN): ", prist_SCAN_band["Br_p"][0,544-1])
#print("Total proj. onto Cs_d from lowest unocc. band at G (PBE): ", prist_PBE_band["Cs_d"][0,545])
#print("Total proj. onto Cs_d from lowest unocc. band at G (r2SCAN): ", prist_SCAN_band["Cs_d"][0,545-1])
#print("Total proj. onto Pb_p from lowest unocc. band at Gamma (PBE): ", prist_PBE_band["Pb_p"][0,545-1])
#print("Total proj. onto Pb_p from lowest unocc. band at Gamma (PBE, KPOINTS_OPT): ", prist_PBE_KOPT_band["Pb_p"][0,545-1])
#print("Total proj. onto Pb_p from lowest unocc. band at Gamma (r2SCAN, KPOINTS_OPT): ", prist_SCAN_KOPT_band["Pb_p"][0,545-1])
#print("Total proj. onto Pb_p from lowest unocc. band at Gamma (r2SCAN, KPOINTS_EXP): ", prist_SCAN_KEXP_band["Pb_p"][4,545-1], "\n")

# atom/orbital projection selections
orbs_s = ["Pb_s", "I_s", "Br_s"]
orbs_p = ["Pb_p", "I_p", "Br_p"]
orbs_d = ["Pb_d", "I_d", "Br_d"]
orbs_sp = ["Pb_s", "I_s", "Br_s", "Pb_p", "I_p", "Br_p"]
orbs_spd_noCs = ["Pb_s", "I_s", "Br_s", "Pb_p", "I_p", "Br_p", "Pb_d", "I_d", "Br_d"]

# band index filter, just want to plot in vicinity of Fermi level
bands_filtered = [515,565]

fig1, ax1 = plt.subplots(1, 1, figsize=(11.0, 7.0))
fig2, ax2 = plt.subplots(1, 1, figsize=(11.0, 7.0))
# full band structure
ax1.plot(prist_SCAN_KEXP_band["kpoint_distances"][4:], prist_SCAN_KEXP_band["bands"][4:,bands_filtered[0]:bands_filtered[1]], c=col[0], linestyle='-', linewidth=1.1)
# atom/orbital projected band structure
prist_SCAN_KEXP_pbands = projected_bands(prist_SCAN_KEXP_band["kpoint_distances"][4:], prist_SCAN_KEXP_band["bands"][4:,bands_filtered[0]:bands_filtered[1]],
                                    prist_SCAN_KEXP_band["Pb_s"][4:-1,bands_filtered[0]:bands_filtered[1]], ax2, linewidth=1.2, cmap="turbo")

#print("I_p at VBM: ", prist_PBE_band["I_p"][:,544-1], "\n")
#print("Pb_p at CBM: ", prist_PBE_band["Pb_p"][:,545-1])
#print(prist_PBE_band["I_p"][0,bands_filtered[0]:bands_filtered[1]-1])

count = 0
for k in kticks:
    kmag_ticks[count] = prist_SCAN_KEXP_band["kpoint_distances"][k+4]
    ax1.axvline(x=kmag_ticks[count], c="black", linestyle='-')
    ax2.axvline(x=kmag_ticks[count], c="black", linestyle='-')
    count=count+1

ax1.axhline(0, c="black", linestyle='--', linewidth=0.9)    
ax1.set_xlim(kmag_ticks[0], kmag_ticks[-1])
ax1.set_ylim(Erange_prist_SCAN)
ax1.set_xticks(kmag_ticks)
ax1.set_xticklabels(kpath, size="medium")
ax1.tick_params(axis="both", direction="in")
ax1.set_ylabel(r"$E-E_F$ [eV]", size="medium")
fig1.tight_layout()
fig1.savefig("./py4vasp_plots/prist_SCAN_KEXP_band.png")

ax2.axhline(0, c="black", linestyle='--', linewidth=0.9)    
ax2.set_xlim(kmag_ticks[0], kmag_ticks[-1])
ax2.set_ylim(Erange_prist_SCAN)
ax2.set_xticks(kmag_ticks)
ax2.set_xticklabels(kpath, size="medium")
ax2.tick_params(axis="both", direction="in")
ax2.set_ylabel(r"$E-E_F$ [eV]", size="medium")
cbar = fig2.colorbar(prist_SCAN_KEXP_pbands)
cbar.set_label("Orbital projection", rotation=270, labelpad=20, size="large")
fig2.tight_layout()
fig2.savefig("./py4vasp_plots/prist_SCAN_KEXP_band_Pb-s.png")