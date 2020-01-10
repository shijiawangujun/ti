import sys
import os
import numpy as np

err = {'system':[],'windows':[]}

systems = ('complex','protein')

windows = ( '{:1.2f}'.format(x) for x in np.arange(0,1.001,0.02))

pwd = os.getcwd()

for system in systems:
    os.chdir(system)
    spwd = os.getcwd()
    for w in windows:
        os.chdir(w)
        with open('ti001.en','r') as f:
            for line in f:
                if line.startswith('L9') and 'dV/dlambda' not in line:
                    line = line.split()
                    dvdl = float(line[5])
                    if dvdl > 1e6:
                        err['system'].append(system)
                        err['windows'].append(w)
                        print('{} {}'.format(system,w))
        os.chdir(spwd)
    os.chdir(pwd)
