#!/bin/sh

cd Occupancy_naive
make clean
make
srun ./occupancy_mxv_naive |& tee occupancy.out
make clean
cd ..

cd Occupancy_shmem
make clean
make
srun ./occupancy_mxv_shmem |& tee occupancy.out
make clean
cd ..

cd Occupancy_shmem_batched
make clean
make
srun ./occupancy_mxv_shmem_batched |& tee occupancy.out
make clean
cd ..

cd Occupancy_shmem_batched_unroll
make clean
make
srun ./occupancy_mxv_shmem_batched_unroll |& tee occupancy.out
make clean
cd ..

cd Occupancy_shmem_A
make clean
make
srun ./occupancy_mxv_shmem_A |& tee occupancy.out
make clean
cd ..

grep GFLOPS Occupancy*/occupancy.out
