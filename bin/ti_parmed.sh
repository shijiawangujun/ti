#!/bin/bash

if [ -d ~/bin/ti_tmpl ];then
    tmpl=~/bin/ti_tmpl
else
    echo "You haven't prepared well"
    exit 1
fi

if [ ! -f complex.parm7 -o ! -f complex.rst7 ];then
    echo "Please make sure the result file of previous step is called complex.parm7 and complex.rst7"
fi


echo "This is the second step of TI: parmed and get prepared for submission"

read -p 'Please input the mask of T0: ' t1mask
read -p 'Please input the mask of T1: ' t2mask
read -p 'Please input the mask of S0: ' s1mask
read -p 'Please input the mask of S1: ' s2mask

echo "Please wait, the process of parmed is a little time costing"

${AMBERHOME}/bin/parmed -p complex.parm7 > parmed_out <<_EOF
loadRestrt complex.rst7
setOverwrite True
tiMerge ${t1mask} ${t2mask} ${s1mask} ${s2mask}
outparm merged.parm7 merged.rst7
outPDB merged.pdb
quit
_EOF

if [ "$?" != "0" ];then
    cat parmed_out
    exit 1
fi

t1mask=$(grep 'timask1' parmed_out)
# t1mask=$(echo ${t1mask}|sed -e "s/'//g" -e "s/,/+/g")
# t1mask=${t1mask%+},
t2mask=$(grep 'timask2' parmed_out)
# t2mask=$(echo ${t2mask}|sed -e "s/'//g" -e "s/,/+/g")
# t2mask=${t2mask%+},
s1mask=$(grep 'scmask1' parmed_out)
# s1mask=$(echo ${s1mask}|sed -e "s/'//g" -e "s/,/+/g")
# s1mask=${s1mask%+},
s2mask=$(grep 'scmask2' parmed_out)
# s2mask=$(echo ${s2mask}|sed -e "s/'//g" -e "s/,/+/g")
# s2mask=${s2mask%+},

read -p 'Please input the distance of ti: ' dis
windows=$(seq 0 ${dis} 1)
num=$(echo "1/${dis}+1"|bc)
read -p 'Please input the time of simulation:(ps) ' simulat_time
nsumlation=$(echo "${simulat_time}*500"|bc)

windows=$(echo ${windows})

if [ ! -d free_energy ];then
    mkdir free_energy
fi

sed -e "s/%MASK%/${t1mask}\n${t2mask}\n${s1mask}\n${s2mask}/g" ${tmpl}/min.tmpl > free_energy/min.tmpl
sed -e "s/%MASK%/${t1mask}\n${t2mask}\n${s1mask}\n${s2mask}/g" ${tmpl}/heat.tmpl > free_energy/heat.tmpl
sed -e "s/%MASK%/${t1mask}\n${t2mask}\n${s1mask}\n${s2mask}/g" -e "s/%SUM_TIME%/${nsumlation}/g" -e "s/%NUM%/${num}/g" -e "s/%BAR%/${windows}/g" ${tmpl}/prod.tmpl > free_energy/prod.tmpl

cp ${tmpl}/sub.sh free_energy
# cp ${tmpl}/smallcheck.py free_energy
sed -e "s/%DIS%/${dis}/g" ${tmpl}/subtmpl.sh > free_energy/Submit.sh

# rm parmed_out

echo "Please check and submit the Submit.sh"
exit 0