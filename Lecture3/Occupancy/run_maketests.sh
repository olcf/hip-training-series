#!/bin/sh

cd Occupancy_naive
make clean
make
srun ./occupancy_mxv_naive >& occupancy.out
make clean
cd ..

cd Occupancy_shmem
make clean
make
srun ./occupancy_mxv_shmem >& occupancy.out
make clean
cd ..

cd Occupancy_shmem_batched
make clean
make
srun ./occupancy_mxv_shmem_batched >& occupancy.out
make clean
cd ..

cd Occupancy_shmem_batched_unroll
make clean
make
srun ./occupancy_mxv_shmem_batched_unroll >& occupancy.out
make clean
cd ..

cd Occupancy_shmem_A
make clean
make
srun ./occupancy_mxv_shmem_A >& occupancy.out
make clean
cd ..

