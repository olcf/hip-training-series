#!/bin/sh

cd Occupancy_naive
make clean
mkdir build && cd build
cmake ..
make
srun ./occupancy_mxv_naive
cd ..
make clean
cd ..

cd Occupancy_shmem
make clean
mkdir build && cd build
cmake ..
make
srun ./occupancy_mxv_shmem
make clean
cd ..
make clean
cd ..

cd Occupancy_shmem_batched
make clean
mkdir build && cd build
cmake ..
make
srun ./occupancy_mxv_shmem_batched
make clean
cd ..
make clean
cd ..

cd Occupancy_shmem_batched_unroll
make clean
mkdir build && cd build
cmake ..
make
srun ./occupancy_mxv_shmem_batched_unroll
make clean
cd ..
make clean
cd ..

cd Occupancy_shmem_A
make clean
mkdir build && cd build
cmake ..
make
srun ./occupancy_mxv_shmem_A
make clean
cd ..
make clean
cd ..

