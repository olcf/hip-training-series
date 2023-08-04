# HIP Lecture Series

## Introduction to HIP Exercises

`git clone https://github.com/amd/HPCTrainingExamples.git`

For the first interactive example, get an slurm interactive session

`salloc -N 1 -p batch --gpus=1 -t 10:00 -A <project>`

```
module load PrgEnv-amd
module load amd
module load cmake
```

### Basic examples

`cd HPCTrainingExamples/HIP/vectorAdd `

Examine files here – README, Makefile, CMakeLists.txt and vectoradd.hip. Notice that Makefile requires ROCM_PATH to be set. Check with module show rocm or echo $ROCM_PATH Also, the Makefile builds and runs the code. We’ll do the steps separately. Check also the HIPFLAGS in the Makefile. There is also a CMakeLists.txt file to use for a cmake build.

For the portable Makefile system
```
make vectoradd
srun ./vectoradd
```
This example also runs with the cmake system

```
mkdir build && cd build
cmake ..
make
srun ./vectoradd
```

We can use a SLURM submission script, let's call it `hip_batch.sh`. There is a sample script
for some systems in the example directory.

```
#!/bin/bash
#SBATCH -p batch
#SBATCH -N 1
#SBATCH --gpus=1
#SBATCH -t 10:00
#SBATCH -A <your project id>

module load PrgEnv-amd
module load amd
cd $HOME/HPCTrainingExamples/HIP/vectorAdd 

make vectoradd
srun ./vectoradd
```

Submit the script
`sbatch hip_batch.sh`

Check for output in `slurm-<job-id>.out` or error in `slurm-<job-id>.err`

To use the cmake option in the batch file, change the build to

```
mkdir build && cd build
cmake ..
make
srun ./vectoradd
```

Compile and run with Cray compiler

```
module load PrgEnv-cray
module load amd-mixed
CXX=CC CRAY_CPU_TARGET=x86-64 make vectoradd
srun ./vectoradd
``` 

```
module load PrgEnv-cray
module load amd-mixed
module load cmake
mkdir build && cd build
CXX=CC CRAY_CPU_TARGET=x86-64 cmake ..
make
srun ./vectoradd
``` 

Now let’s try the hip-stream example. This example is from the original McCalpin code as ported to CUDA by Nvidia. This version has been ported to use HIP.

```
module load PrgEnv-amd
module load amd
cd $HOME/HPCTrainingExamples/HIP/hip-stream
make
srun ./stream
```
Note that it builds with the hipcc compiler. You should get a report of the Copy, Scale, Add, and Triad cases.

On your own:

1. Check out the saxpy example in `HPCTrainingExamples/HIP`
2. Write your own kernel and run it
3. Test the code on an Nvidia system -- Add `HIPCC=nvcc` before the make command or `-DCMAKE_GPU_RUNTIME=CUDA` to the cmake command. (See README file)

### More advanced HIP makefile

The jacobi example has a more complex build that incorporates MPI. The original Makefile has not been modified, but a CMakeLists.txt has been
added to demonstrate a portable cmake build. From an interactive session, try the following steps

```
cd $HOME/HPCTrainingExamples/HIP/jacobi

module load PrgEnv-amd
module load amd
module load cray-mpich
module load cmake

mkdir build && cd build
cmake ..
make
srun -n 1 ./Jacobi_hip
```
