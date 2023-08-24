#!/bin/bash
#SBATCH -N 1
#SBATCH -q shared
#SBATCH -C gpu
#SBATCH -c 32
#SBATCH -G 1
#SBATCH -t 00:30:00
#SBATCH -A ntrain8
####SBATCH ---reservation hip_aug28

cd $HOME/hip-training-series/Lecture2/HIPIFY/mini-nbody/cuda
hipify-perl -print-stats nbody-orig.cu > nbody-orig.cpp
hipcc -DSHMOO -I ../ nbody-orig.cpp -o nbody-orig
srun ./nbody-orig
cd ../../..
