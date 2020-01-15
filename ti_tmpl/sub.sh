#!/bin/bash

#PBS -N %NN%-%L%
#PBS -q gpuq
#PBS -l nodes=gpu04:ppn=8
#PBS -l walltime=120:00:00
#PBS -j oe

#start from 0 
export CUDA_VISIBLE_DEVICES="%N%"
PRMTOP="../../*.prmtop"
INPCRD="../*.inpcrd"
#source /home/faculty/hfchen/environment2

# This job's working directory
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
runmpi="mpirun -np 10 pmemd.MPI"

#mpirun -lsf 
pmemd -i min.in -c ti.rst7 -ref ti.rst7 -p ti.parm7 -O -o min.out -inf min.info -e min.en -r min.rst7 -l min.log
${runmpi} -i min.in -c ti.rst7 -ref ti.rst7 -p ti.parm7 -O -o min.out -inf min.info -e min.en -r min.rst7 -l min.log

#mpirun -lsf 
$mdrun -i heat.in -c min.rst7 -ref ti.rst7 -p ti.parm7 -O -o heat.out -inf heat.info -e heat.en -r heat.rst7 -x heat.nc -l heat.log
#${runmpi} -i heat.in -c min.rst7 -ref ti.rst7 -p ti.parm7 -O -o heat.out -inf heat.info -e heat.en -r heat.rst7 -x heat.nc -l heat.log

#$mdrun -i equil.in -c heat.rst7 -ref ti.rst7 -p ti.parm7 -O -o equil.out -inf equil.info -e equil.en -r equil.rst7 -x equil.nc -l equil.log
#${runmpi} -i equil.in -c heat.rst7 -ref ti.rst7 -p ti.parm7 -O -o equil.out -inf equil.info -e equil.en -r equil.rst7 -x equil.nc -l equil.log

#mpirun -lsf 
$mdrun -i ti.in -c heat.rst7 -p ti.parm7 -O -o ti001.out -inf ti001.info -e ti001.en -r ti001.rst7 -x ti001.nc -l ti001.log
#${runmpi} -i ti.in -c heat.rst7 -p ti.parm7 -O -o ti001.out -inf ti001.info -e ti001.en -r ti001.rst7 -x ti001.nc -l ti001.log


# Report tail
echo "******************************************************" >> $PBS_O_WORKDIR/$LOGFILE
echo "Finished at:""    "`date` >> $PBS_O_WORKDIR/$LOGFILE
echo "######################################################" >> $PBS_O_WORKDIR/$LOGFILE
echo "######################################################" >> $PBS_O_WORKDIR/$LOGFILE
echo " ">> $PBS_O_WORKDIR/$LOGFILE
