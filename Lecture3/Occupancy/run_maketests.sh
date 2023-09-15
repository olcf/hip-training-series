#!/bin/sh

cd Occupancy_naive
make clean
make
make test
make clean
cd ..

cd Occupancy_shmem
make clean
make
make test
make clean
cd ..

cd Occupancy_shmem_batched
make clean
make
make test
make clean
cd ..

cd Occupancy_shmem_batched_unroll
make clean
make
make test
make clean
cd ..

cd Occupancy_shmem_A
make clean
make
make test
make clean
cd ..

