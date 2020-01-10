#!/bin/bash

. windows
    for w in $windows
    do
	if [ -d $w ];then
            cd $w
	else
	    echo "${step}  ${w} haven't finished yet"
	    continue
	fi
        tmp=$(tail -n1 ti001.out|grep Total)
        if [ "$tmp" == "" ];then
            echo "${step}  ${w} haven't finished yet."
        fi
        cd ..
    done
