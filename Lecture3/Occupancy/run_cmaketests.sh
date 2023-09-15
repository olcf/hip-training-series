#!/bin/sh

cd Occupancy_naive
make clean
mkdir build && cd build
cmake ..
make
srun ./occupancy_mxv_naive |& tee occupancy.out
cd ..
make clean
cd ..

cd Occupancy_shmem
make clean
mkdir build && cd build
cmake ..
make
srun ./occupancy_mxv_shmem |& tee occupancy.out
make clean
cd ..
make clean
cd ..

cd Occupancy_shmem_batched
make clean
mkdir build && cd build
cmake ..
make
srun ./occupancy_mxv_shmem_batched |& tee occupancy.out
make clean
cd ..
make clean
cd ..

cd Occupancy_shmem_batched_unroll
make clean
mkdir build && cd build
cmake ..
make
srun ./occupancy_mxv_shmem_batched_unroll |& tee occupancy.out
make clean
cd ..
make clean
cd ..

cd Occupancy_shmem_A
make clean
mkdir build && cd build
cmake ..
make
srun ./occupancy_mxv_shmem_A |& tee occupancy.out
make clean
cd ..
make clean
cd ..

grep GFLOPS Occupancy*/occupancy.out

