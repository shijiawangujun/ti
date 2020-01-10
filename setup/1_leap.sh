#!/bin/sh
#
# Method 1: setup for a fully dual-topology side chain residue
#

tleap=$AMBERHOME/bin/tleap
basedir=leap


$tleap -f - <<_EOF
# load the AMBER force fields
source leaprc.protein.ff15ipq
source leaprc.water.tip3p
source leaprc.gaff
loadAmberParams frcmod.ionsjc_tip3p

# load force field parameters for BNZ

MOL=loadmol2 $basedir/curk9EC.mol2
loadamberparams $basedir/curk9EC.frcmod
loadamberprep $basedir/curk9EC.prep

# load the coordinates and create the systems
ligand = loadpdb $basedir/mol.pdb
m1 = loadpdb $basedir/curk.pdb
m2 = loadpdb $basedir/curkpvv.pdb
#w = loadpdb $basedir/water_ions.pdb

protein = combine {m1 m2 }
charge protein
complex = combine {m1 m2 ligand }
charge complex
#I don't know why do this
set default nocenter on

# create protein in solution
addions protein Na+ 14
solvateoct protein TIP3PBOX 8
savepdb protein protein.pdb
saveamberparm protein protein.parm7 protein.rst7

# create complex in solution
addions complex Na+ 14
solvateoct complex TIP3PBOX 8
savepdb complex complex.pdb
saveamberparm complex complex.parm7 complex.rst7

quit
_EOF
