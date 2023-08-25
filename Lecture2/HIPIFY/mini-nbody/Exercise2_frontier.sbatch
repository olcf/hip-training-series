#!/bin/bash
#SBATCH -N 1
#SBATCH --ntasks=1
#SBATCH --gpus=1
#SBATCH -p batch
#SBATCH -t 00:10:00
#SBATCH -A <project id>
#####SBATCH --reservation <reservation_name>

module load PrgEnv-amd
module load amd
module load cmake

cd $HOME/hip-training-series/Lecture2/HIPIFY/mini-nbody/cuda
hipify-perl -print-stats nbody-orig.cu > nbody-orig.cpp
hipcc -DSHMOO -I ../ nbody-orig.cpp -o nbody-orig
srun ./nbody-orig
cd ../../..
