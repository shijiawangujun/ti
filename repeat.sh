#!/bin/bash

echo "This is a program to repeat Thermodynamic Intergal."

if [ ! -d free_energy ];then
    echo "Please execute the ti_parmed at least once at this folder before this program"
    exit 1
fi

if [ "${1}" == "-n" -a "$2" != "" ];then
    NUMBER=$2
elif [ ${1} != "" ];then
    echo "ERROR INPUT"
else
    read -p "Please input the times that you want to repeat: " NUMBER
fi

declare -i n=0

while [ -d  free_energy_${n} ]
do
    ((n++))
done

# echo $n

windows=$(seq ${n} 1 $(echo "${n}+${NUMBER}-1"|bc) )
echo ${windows}

for w in ${windows}
do
    mkdir free_energy_${w}
    cp free_energy/*.sh free_energy/*.tmpl free_energy/*.py free_energy_${w}
done

exit 0
