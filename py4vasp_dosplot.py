import py4vasp
import matplotlib.pyplot as plt
import matplotlib._color_data as mcd
import matplotlib.colors as mcol
import matplotlib.ticker as tick
from collections.abc import Iterable

# Cs doesn't contribute anything significant near Fermi level
# also Pb/I/Br s states further down in valence bulk states
# so can leave out if plotting close to E_F
EF_prist_PBE =  1.164 # VBM energy output from the DOSCAR; not actually E_F
EF_prist_SCAN = 0.908
EF_VI_PBE = 1.096 # VBM not the highest occupied level due to defect donor states
Erange_full = [-15, 8]
Erange_half = [-7.5, 7]
Erange_prist_PBE = [-2.37-EF_prist_PBE, 6.39-EF_prist_PBE]
Erange_prist_SCAN = [-2.74-EF_prist_SCAN, 6.47-EF_prist_SCAN]
Erange_VI_PBE = [-2.38-EF_VI_PBE, 6.32-EF_VI_PBE]

# need to cat colour lists together if >10 orbitals (tableau list size 10 I think)
col = list(mcol.TABLEAU_COLORS) + list(mcol.TABLEAU_COLORS)

prist_PBE_calc = py4vasp.Calculation.from_path("./Pristine")
prist_PBE_dos = prist_PBE_calc.dos.read(selection="s(Pb,I,Br), p(Pb,I,Br)")
prist_SCAN_calc = py4vasp.Calculation.from_path("./{ristine_r2SCAN")
prist_SCAN_dos = prist_SCAN_calc.dos.read(selection="s(Pb,I,Br), p(Pb,I,Br)")

# atom/orbital projection selections
orbs_sp = ["Pb_s", "I_s", "Br_s", "Pb_p", "I_p", "Br_p"]
orbs_p = ["Pb_p", "I_p", "Br_p"]
#print(prist_PBE_dos)

fig, ax = plt.subplots(1, 1, figsize=(8.0, 4.0))
count = 0
for key in orbs_p:
    ax.plot(prist_SCAN_dos["energies"],prist_SCAN_dos[f"{key}"],label=orbs_p[count], c=col[count], linestyle='-')
    count=count+1
ax.plot(prist_SCAN_dos["energies"],prist_SCAN_dos["total"],label="Total", c="black", linestyle='-')
ax.axvline(x=0, c="black", label="$E_F$", linestyle='--')
ax.set_xlim(Erange_prist_SCAN)
ax.set_ylim(0,max(prist_SCAN_dos["total"])+20)
ax.set_xlabel("Energy [eV]")
ax.set_ylabel("DOS [a.u.]")
ax.legend(bbox_to_anchor=(1.01, 1.04), loc="upper left")
fig.tight_layout()
fig.savefig("./py4vasp_plots/prist_SCAN_pdos.png")