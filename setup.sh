#!/bin/bash
basedir=$(cd $(dirname $0);pwd -P)

echo "This is the setup program for thermodynamic intergal"
echo "Supported by SJTU CCMBI"

if [ ! -f ~/bin ];then
    mkdir ~/bin
fi

if [[ ! "${PATH}" ~= .*${HOME}/bin.* ]];then
    echo "Please make sure the folder ~/bin is contained in the PATH"
fi

for bin_file in $(ls ${basedir}/bin)
do
    cp ${basedir}/bin/${bin_file} ~/bin && chmod u+x ~/bin/${bin_file}
done

cp -r tmpl ~/bin/

