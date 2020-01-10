import sys

with open('ti001.en','r') as f:
    for line in f:
        if line.startswith('L9') and not 'dV/dlambda' in line:
            line = line.split()
            dvdl = float(line[5])
            if abs(dvdl) > 1e6:
                sys.exit(1)

sys.exit(0)