import numpy as np
import matplotlib.pyplot as plt
from matplotlib.collections import LineCollection

# function to draw set of coloured lines in for loop
# specifically for plotting atom and/or orbital projected bands from VASP calculation
# x is the line of kpoints [array], y is set of band eigenvalues [matrix], c is atom/orbital projection weights [matrix]
# give y,c as matrices so that can loop over each band index for all kpoints, for easy plotting
# ensure no. kpoints equal for all x,y,c
# ensure no. bands equal for y,c
def projected_bands(x, y, c, ax=None, **lc_kwargs):
    nbands = len(y[1,:])
    for j in range(nbands):
        #xy = np.stack((x, y[:,j]), axis=-1)
        #xy_mid = np.concat(
        #    (xy[0, :][None, :], (xy[:-1, :] + xy[1:, :]) / 2, xy[-1, :][None, :]), axis=0
        #)
        #segments = np.stack((xy_mid[:-1, :], xy, xy_mid[1:, :]), axis=-2)
        points = np.array([x, y[:,j]]).T.reshape(-1, 1, 2)
        segments = np.concatenate([points[:-2], points[1:-1], points[2:]], axis=1)
       
        #lc_kwargs["array"] = c[:,j]
        lc = LineCollection(segments, **lc_kwargs)

        # Set the values used for colormapping
        lc.set_array(c[:,j])
        lc.set_clim(0,1)

        ax.add_collection(lc)
        
    #return ax.add_collection(lc)
    return lc

#def colored_line(x, y, c, ax=None, **lc_kwargs):
#    xy = np.stack((x, y), axis=-1)
#    xy_mid = np.concat(
#        (xy[0, :][None, :], (xy[:-1, :] + xy[1:, :]) / 2, xy[-1, :][None, :]), axis=0
#    )
#    segments = np.stack((xy_mid[:-1, :], xy, xy_mid[1:, :]), axis=-2)
#    # Note that
#    # segments[0, :, :] is [xy[0, :], xy[0, :], (xy[0, :] + xy[1, :]) / 2]
#    # segments[i, :, :] is [(xy[i - 1, :] + xy[i, :]) / 2, xy[i, :],
#    #     (xy[i, :] + xy[i + 1, :]) / 2] if i not in {0, len(x) - 1}
#    # segments[-1, :, :] is [(xy[-2, :] + xy[-1, :]) / 2, xy[-1, :], xy[-1, :]]
#
#    lc_kwargs["array"] = c
#    lc = LineCollection(segments, **lc_kwargs)
#
#    # Plot the line collection to the axes
#    ax = ax or plt.gca()
#    ax.add_collection(lc)
#
#    return lc


# -------------- Create and show plot --------------
# Some arbitrary function that gives x, y, and color values
#t = np.linspace(-7.4, -0.5, 200)
#x = 0.9 * np.sin(t)
#y = 0.9 * np.cos(1.6 * t)
#color = np.linspace(0, 1, t.size)

# Create a figure and plot the line on it
#fig1, ax1 = plt.subplots()
#lines = colored_line(x, y, color, ax1, linewidth=2, cmap="jet")
#ax1.set_xlim([-1,1])
#ax1.set_ylim([-1,1])
#fig1.colorbar(lines)  # add a color legend
#fig1.savefig("test.png")