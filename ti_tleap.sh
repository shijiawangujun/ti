#!/bin/bash

if [ -d ~/bin/tmpl ];then
    tmpl="~/bin/tmpl"
else
    echo "You haven't prepared well"
    exit 1
fi

echo "This is the first step of IT:tleap"

read -n1 -p "Do you want to use the leap.in file that has already existed?[y/n]  " answer
if [[ "${answer}" ~= [Y|y] ]];then
    if [ -f leap.in ];then
        tleap -f leap.in
    else
        echo "There is no leap.in file"
        exit 1
    fi
elif [[ "${answer}" ~= [N|n] ]];then
    cp ${tmpl}/leap.in .
    vi leap.in
    tleap -f leap.in
else 
    echo "wrong input"
    exit 1
fi

if [ "$?" != "0" ];then
    echo "There is some error with tleap."
    exit 1
fi

exit 0