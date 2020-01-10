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

# Revision:  Jun 1 2013  thundawner
#
# for amber_cuda jobs on SKMML Sugon Cluster
#
# Usage: gensub_amber_cuda
#
#

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

#Run amber12 Job
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

#pmemd.cuda -O -p $PRMTOP -c $INPCRD -i min1.in -o min1.out -r min1.rst -ref $INPCRD
#pmemd.cuda -O -p $PRMTOP -c min1.rst -i min.in -o min.out -r min.rst -ref min1.rst
#pmemd.cuda -O -p $PRMTOP -c min.rst -i heat.in -o heat.out -r heat.rst -x heat.mdcrd -ref min.rst
#pmemd.cuda -O -p $PRMTOP -c heat.rst -i equil.in -o equil.out -r equil.rst -x equil.mdcrd -ref heat.rst
#mpirun -np 2 pmemd.cuda.MPI -O -i amd.in -p $PRMTOP -c equil.rst  -o amd1.out -r amd1.rst -x amd1.nc
#pmemd.cuda -O -p $PRMTOP -c equil.rst -i md.in -o md1.out -r md1.rst -x md1.mdcrd
#pmemd.cuda -O -p $PRMTOP -c md1.rst -i md.in -o md1_2.out -r md1_2.rst -x md1_2.mdcrd
#cpptraj $PRMTOP  hb.in >hb.out
#cpptraj $PRMTOP  DCCM.in >DCCM.out
#cpptraj $PRMTOP  cluster.in >cluster.out
#cpptraj $PRMTOP  rmsf.in >rmsf.out
#cpptraj $PRMTOP  cpptrajdist.in>cpptrajdist.out

# Report tail
echo "******************************************************" >> $PBS_O_WORKDIR/$LOGFILE
echo "Finished at:""    "`date` >> $PBS_O_WORKDIR/$LOGFILE
echo "######################################################" >> $PBS_O_WORKDIR/$LOGFILE
echo "######################################################" >> $PBS_O_WORKDIR/$LOGFILE
echo " ">> $PBS_O_WORKDIR/$LOGFILE
