#!/bin/bash

function myfunction()
{
/home/apps/anaconda3/bin/python << _EOF
import sys

with open('ti001.en','r') as f:
    for line in f:
        if line.startswith('L9') and not 'dV/dlambda' in line:
            line = line.split()
            dvdl = float(line[5])
            if dvdl > 1e6:
                sys.exit(1)

sys.exit(0)
_EOF
entest=$?
}

windows=$(seq 0.0 0.02 1.0)

for system in protein complex
do
    cd $system
    for w in $windows
    do 
        cd $w
        if [ "$(tail -n1 ti001.out|grep Total)" == "" ]
        then
            echo "There is some error in the ${system} ${w}"
        else
            myfunction

            while [ "${entest}" != "0" ]
            do
                # pmemd -i min.in -c ti.rst7 -ref ti.rst7 -p ti.parm7 -O -o min.out -inf min.info -e min.en -r min.rst7 -l min.log
                # pmemd.cuda -i heat.in -c min.rst7 -ref ti.rst7 -p ti.parm7 -O -o heat.out -inf heat.info -e heat.en -r heat.rst7 -x heat.nc -l heat.log
                # pmemd.cuda -i ti.in -c heat.rst7 -p ti.parm7 -O -o ti001.out -inf ti001.info -e ti001.en -r ti001.rst7 -x ti001.nc -l ti001.log
                echo "something error in the ${system} ${w} !"                
                myfunction
            done
        fi
        cd ..
    done
    cd ..
done