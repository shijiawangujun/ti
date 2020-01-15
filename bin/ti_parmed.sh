echo "This is the second step of TI: parmed and get prepared for submission"

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
#!/bin/bash

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