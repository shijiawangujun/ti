#!/home/apps/anaconda3/bin/python
#it's a progam which uses python3 instead of python2
import math
import os,sys,glob
import numpy as np
import pandas as pd
import glob

skip=5
glob_pattern = 'ti001.en'
windows = glob.glob(r'[01].*')
if len(windows) == 0:
    print('ERROR LOCATION')
    sys.exit(1)
windows.sort(key=lambda x:float(x))
extrap = 'polyfit'

data=pd.DataFrame(columns=['mean','err','std'])
data.index.name='step'
# data.index.name='type'

cwd = os.getcwd()
for window in windows:
    os.chdir(window)
    
    ln=0
    w_enfile=[]
    #to open the file with system pattern
    for en in glob.glob(glob_pattern):
        
        with open(en,'r') as en_file:
            for line in en_file:
                ln += 1
                if ln >skip and (line.startswith('L9') and not 'dV/dlambda' in line):
                    w_enfile.append(float(line.split()[5]))

    mean,std = np.mean(w_enfile),np.std(w_enfile)
    err=std/(math.sqrt(len(w_enfile))-1)

    w_enfile=pd.DataFrame(w_enfile)
    w_enfile.to_csv('en.csv',header=False,index=False)
    tmp_series=pd.Series({'mean':mean,'err':err,'std':std},name=float(window))
    data=data.append(tmp_series)
    os.chdir(cwd)

data.to_csv(path_or_buf='dVdl.csv')
y = np.array(data['mean'])
x = np.array(data.index)


if extrap == 'linear':
    if 0.0 not in x:
        l = (x[0]*y[1] - x[1]*y[0]) / (x[0] - x[1])
        x.insert(0, 0.0)
        y.insert(0, l)

    if 1.0 not in x:
        l = ( (x[-2] - 1.0)*y[-1] + ((1.0-x[-1])*y[-2]) ) / (x[-2] - x[-1])
        x.append(1.0)
        y.append(l)
elif extrap == 'polyfit' and (0.0 not in x or 1.0 not in x):
    if len(x) < 6:
        deg = len(x) - 1
    else:
        deg = 6

    coeffs = np.polyfit(x, y, deg)

    if 0.0 not in x:
        x.insert(0, 0.0)
        y.insert(0, coeffs[-1])

    if 1.0 not in x:
        x.append(1.0)
        y.append(sum(coeffs) )

with open('dvdl.dat','w') as f:
    for a, b in zip(x, y):
        if a in data.index:
            v = data.loc[a]
            print('{} {} {} {}'.format(a, v[0], v[1], v[2]),file=f)
        else:
            print ('{} {}'.format(a, b),file=f)

print('# dG = {}'.format (np.trapz(y, x)))
