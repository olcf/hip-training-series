
# Instructions for running examples on Perlmutter:

On Perlmutter, the exercise is to compare the performance change on Nvidia GPUs for each type of optimization

To load the appropriate modules, 

```
module load PrgEnv-gnu/8.3.3
module load hip/5.4.3
module load PrgEnv-nvidia/8.3.3
module load cmake

export PATH=${PATH}:${HIP_PATH}
```

To get an allocation on Perlmutter

```
salloc -N 1 -q shared -C gpu -c 32 -G 1 -t 30:00 -A ntrain8 --reservation=hip_oct16
```

Outside the reservation hours use,

```
salloc -N 1 -q shared -C gpu -c 32 -G 1 -t 30:00 -A ntrain8
```

