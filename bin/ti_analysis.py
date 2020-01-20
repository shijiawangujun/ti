#!/home/apps/anaconda3/bin/python
#it's a progam which uses python3 instead of python2
#%%
import math
import os,sys,glob
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy.stats.mstats import kruskalwallis

#%%
# os.chdir('../../example/free_energy')

#%%
skip=5
glob_pattern = ['ti0.en','ti1.en','ti2.en']
windows = glob.glob(r'[01].*')
if len(windows) == 0:
    print('ERROR LOCATION')
    sys.exit(1)
windows.sort(key=lambda x:float(x))
extrap = 'polyfit'

#%%
data = pd.DataFrame(columns=['mean','err','std','pvalue'])
data.index.name = 'step'
# data.index.name='type'
#%%
cwd = os.getcwd()
for window in windows:
    os.chdir(window)
    
    ln=0
    w_enfile=[]
    #to open the file with system pattern
    for en in glob_pattern:       
        with open(en,'r') as en_file:
            for line in en_file:
                ln += 1
                if ln >skip and (line.startswith('L9') and not 'dV/dlambda' in line):
                    w_enfile.append(float(line.split()[5]))

    plt.switch_backend('agg')

    fig = plt.figure(figsize=(14,8),dpi=300)
    ax = fig.add_subplot(1,1,1)
    length = len(w_enfile)
    sall = pd.Series(w_enfile)
    for i in range(0,3,1):
        s = sall[i*length//3:(i+1)*length//3]
        s.plot(ax=ax,kind='kde',label='ti{}'.format(i))
        # ax.plot(x=w_enfile[i*length//3:(i+1)*length//3],kind='kde',label='ti{}'.format(i))
    ax.set_title('Comparation',fontsize='xx-large')
    ax.set_xlabel('dG(kcal/mol)',fontsize='x-large')
    ax.set_ylabel('Density',fontsize='x-large')
    ax.legend(loc='best')

    fig.savefig('ti{}.png'.format(window))
    fig.savefig('ti{}.pdf'.format(window))

    mean,std = np.mean(w_enfile),np.std(w_enfile)
    err = std/(math.sqrt(len(w_enfile))-1)
    h,pvalue = kruskalwallis(w_enfile[0:length//3],w_enfile[length//3:length*2//3],w_enfile[length//3*2:length])

    w_enfile = pd.DataFrame(w_enfile)
    w_enfile.to_csv('en.csv',header=False,index=False)
    tmp_series = pd.Series({'mean':mean,'err':err,'std':std,'pvalue':pvalue},name=float(window))
    data = data.append(tmp_series)
    os.chdir(cwd)

data.to_csv(path_or_buf='dVdl.csv')
#%%
y = np.array(data['mean'])
# print(y)
# print(data.mean)
# print(np.array(data['mean']))
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

# Write to the dVdl.dat file
with open('dVdl.dat','w') as f:
    for a, b in zip(x, y):
        if a in data.index:
            v = data.loc[a]
            print('{} {} {} {}'.format(a, v[0], v[1], v[2]),file=f)
        else:
            print ('{} {}'.format(a, b),file=f)

print('# dG = {}'.format (np.trapz(y, x)))
#%%
#%matplotlib inline
plt.switch_backend('agg')

fig = plt.figure(figsize=(14,8),dpi=300)
ax = fig.add_subplot(1,1,1)

# ax.stackplot(x=data.index,y=data.mean)
# ax.plot(x=data.index,y=data.mean,fmt='o-',col='#ADA996')
ax.fill_between(x=x,y1=y,alpha=0.9,color='#A5FECB')
ax.errorbar(x=x,y=y,yerr=data.err,fmt='o--',ecolor='#5433FF',c='#20BDFF')
ax.set_xticks(np.arange(0,1.01,0.1))
ax.set_xlabel('dlambda',fontsize='large',fontweight='demibold')
ax.set_ylabel('dV/dl(kcal/mol)',fontsize='large',fontweight='demibold')
ax.set_title('Thermodynamic Integral',fontsize='xx-large',fontweight='bold')

fig.savefig('dVdl.png')
fig.savefig('dVdl.pdf')


# %%
