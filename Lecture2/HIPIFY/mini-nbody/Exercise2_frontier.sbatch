#!/bin/bash
#SBATCH -N 1
#SBATCH --ntasks=1
#SBATCH --gpus=1
#SBATCH -p batch
#SBATCH -A VEN114
#SBATCH -t 00:10:00
#####SBATCH --reservation hip_training_2023_8_28

module load PrgEnv-amd
module load amd
module load cmake

cd $HOME/hip-training-series/Lecture2/HIPIFY/mini-nbody/cuda
hipify-perl -print-stats nbody-orig.cu > nbody-orig.cpp
hipcc -DSHMOO -I ../ nbody-orig.cpp -o nbody-orig
srun ./nbody-orig
cd ../../..
