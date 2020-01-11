#!/bin/bash

if [ -d "~/bin/ti_tmpl" ];then
    tmpl="~/bin/ti_tmpl"
else
    echo "You haven't prepared well"
    exit 1
fi

echo "This is the first step of IT:tleap"

read -n1 -p "Do you want to use the leap.in file that has already existed?  " answer
if [[ "${answer}" ~= [Y|y] ]];then
    if [ -f leap.in ];then
        tleap -f leap.in
    else
        echo "There is no leap.in file"
        exit 1
    fi
else
    cp ${tmpl}/leap.in .
    vi leap.in
    tleap -f leap.in
fi

if [ "$?" != "0" ];then
    echo "There is some error with tleap."
    exit 1
fi

echo "This is the second step of TI: parmed and get prepared for submission"
echo "Please ckeck the result of tleap, and find the mask of the thermodynamic intergal."
sleep 5

vim complex.pdb

read -p 'Please input the mask of T0: ' t1mask
read -p 'Please input the mask of T1: ' t2mask
read -p 'Please input the mask of S0: ' s1mask
read -p 'Please input the mask of S1: ' s2mask

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
t2mask=$(grep 'timask2' parmed_out)
s1mask=$(grep 'scmask1' parmed_out)
s2mask=$(grep 'scmask2' parmed_out)

rm parmed_out

read -p 'Please input the distance of ti: ' dis
windows=$(seq 0 ${dis} 1)
num=$(echo "1/${dis}+1"|bc)
read -p 'Please input the time of simulation:(ps) ' simulat_time
nsumlation=$(echo "${simulat_time}*500"|bc)

if [ ! -d free_energy ];then
    mkdir free_energy
fi

sed -e "s/%MASK%/${t1mask}${t2mask}${s1mask}${s2mask}/g" ${tmpl}/min.tmpl > free_energy/min.tmpl
sed -e "s/%MASK%/${t1mask}${t2mask}${s1mask}${s2mask}/g" ${tmpl}/heat.tmpl > free_energy/heat.tmpl
sed -e "s/%MASK%/${t1mask}${t2mask}${s1mask}${s2mask}/g" -e "s/%SUM_TIME%/${nsumlation}/g" -e "s/%NUM%/${num}/g" -e "s/%BAR%/${windows}/g" ${tmpl}/prod.tmpl > free_energy/prod.tmpl

cp ${tmpl}/smallcheck.py free_energy
sed -e "s/%DIS%/${dis}/g" ${tmpl}/subtmpl.sh > free_energy/Submit.sh

echo "Please check and submit the Submit.sh"
exit 0