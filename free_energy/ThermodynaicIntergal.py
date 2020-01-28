#!/home/apps/anaconda3/bin/python3
#%%
import os,sys,re
import parmed as pmd
from parmed.tools import tiMerge


with open('tmpfile','w') as f:
    tiMerge.output = f
    parm = pmd.load_file('./protein.parm7',xyz='./protein.rst7')
    act = tiMerge(parm,':1-14',':15-28', ':4@S2P', ':18@O2P')
    act.execute()
    parm.save('filename')

#%%
a = input('cout')

# %%
