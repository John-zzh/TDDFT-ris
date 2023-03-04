#!/bin/bash

module load turbomole

rm -rf ris risp only_control only_basis no_fe


mkdir ris
cd ris
echo "TDDFT-ris"
cp ../Fe_backup/* ./
sh ../../escfrisprep.sh 
sbatch escf.slurm
cd ..
echo '========================================'


mkdir risp
cd risp
echo "TDDFT-risp"
cp ../Fe_backup/* ./
sh ../../escfrisprep.sh -b s+p
sbatch escf.slurm
cd ..
echo '========================================'

mkdir only_control
cd only_control
cp ../Fe_backup/* ./
sh ../../escfrisprep.sh -b N
cd ..
echo '========================================'

mkdir only_basis
cd only_basis
cp ../Fe_backup/* ./
sh ../../escfrisprep.sh -c N
cd ..
echo '========================================'

mkdir no_fe
cd no_fe
cp ../Fe_backup/* ./
sh ../../escfrisprep.sh -x fe
sbatch escf.slurm
cd ..
echo '========================================'