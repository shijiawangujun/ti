#!/bin/bash
#PBS -N Holo-DNA-TI
#PBS -q gpuq
#PBS -l nodes=gpu02:ppn=8
#PBS -l walltime=120:00:00
#PBS -j oe

function myfunction()
{
    /home/apps/anaconda3/bin/python ${top}/smallcheck.py
    entest=$?
}

#start from 0 
export CUDA_VISIBLE_DEVICES="2"

cd $PBS_O_WORKDIR

TmpID=`echo $PBS_JOBID | gawk -F. '{print $1}'`

LOGFILE=report_log_${TmpID}

NPROCS=`wc -l < $PBS_NODEFILE`
echo This job has allocated $NPROCS nodes

# Report head
echo "######################################################" >> $PBS_O_WORKDIR/$LOGFILE
echo "######################################################" >> $PBS_O_WORKDIR/$LOGFILE
echo "New job submited," >> $PBS_O_WORKDIR/$LOGFILE
echo "Name:""           "$INPUTFILE >> $PBS_O_WORKDIR/$LOGFILE
echo "Start at:""       "`date` >> $PBS_O_WORKDIR/$LOGFILE
echo "Directory:""      "`pwd` >> $PBS_O_WORKDIR/$LOGFILE
echo "Running on" `hostname`", using" $NPROCS "processors" >> $PBS_O_WORKDIR/$LOGFILE
mdrun=$AMBERHOME/bin/pmemd.cuda
# runmpi="mpirun -np 10 pmemd.MPI"

# the step of the md simulation
windows=$(seq 0.0 %DIS% 1.0)
top=$PWD
for w in $windows
do
    if [ \! -d $w ]; then
        mkdir $w
    fi
    sed -e "s/%L%/$w/" min.tmpl > $w/min.in
    sed -e "s/%L%/$w/" heat.tmpl > $w/heat.in
    sed -e "s/%L%/$w/" prod.tmpl > $w/ti.in

    cd $w
    #prepare the file
    ln -sf ../../merged.parm7 ti.parm7
    ln -sf ../../merged.rst7  ti.rst7
    #rum md simulation
    pmemd -i min.in -c ti.rst7 -ref ti.rst7 -p ti.parm7 -O -o min.out -inf min.info -e min.en -r min.rst7 -l min.log
    pmemd.cuda -i heat.in -c min.rst7 -ref ti.rst7 -p ti.parm7 -O -o heat.out -inf heat.info -e heat.en -r heat.rst7 -x heat.nc -l heat.log
    pmemd.cuda -i ti.in -c heat.rst7 -p ti.parm7 -O -o ti001.out -inf ti001.info -e ti001.en -r ti001.rst7 -x ti001.nc -l ti001.log
    
    # check the out file
    if [ "$(tail -n1 ti001.out|grep Total)" == "" ]
    then
        echo "There is some errors in the ${w}"
        cd ..
        continue
    else
        myfunction
        #run until the value becomes stable
        while [ "${entest}" != "0" ]
        do
            pmemd -i min.in -c ti.rst7 -ref ti.rst7 -p ti.parm7 -O -o min.out -inf min.info -e min.en -r min.rst7 -l min.log
            pmemd.cuda -i heat.in -c min.rst7 -ref ti.rst7 -p ti.parm7 -O -o heat.out -inf heat.info -e heat.en -r heat.rst7 -x heat.nc -l heat.log
            pmemd.cuda -i ti.in -c heat.rst7 -p ti.parm7 -O -o ti001.out -inf ti001.info -e ti001.en -r ti001.rst7 -x ti001.nc -l ti001.log
            
            myfunction
        done
    fi
    cd ..
done


# Report tail
echo "******************************************************" >> $PBS_O_WORKDIR/$LOGFILE
echo "Finished at:""    "`date` >> $PBS_O_WORKDIR/$LOGFILE
echo "######################################################" >> $PBS_O_WORKDIR/$LOGFILE
echo "######################################################" >> $PBS_O_WORKDIR/$LOGFILE
echo " ">> $PBS_O_WORKDIR/$LOGFILE
