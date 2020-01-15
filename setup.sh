#!/bin/bash

echo "This is the setup program for thermodynamic intergal"
echo "Supported by SJTU CCMBI"

if [ ! -f ~/bin ];then
    mkdir ~/bin
fi

if [[ ! "${PATH}" ~= .*${HOME}/bin.* ]];then
    echo "Please make sure the folder ~/bin is contained in the PATH"
fi

cp ti_parmed.sh ~/bin && chmod u+x ~/bin/ti_parmed.sh
cp ti_tleap.sh ~/bin && chmod u+x ~/bin/ti_tleap.sh
cp analysis.py ~/bin && chmod u+x ~/bin/analysis
cp -r tmpl ~/bin/

