# HIP Lecture Series

## GPU Profiling -- Performance Timelines

For the HIP Lecture Series, the examples can be retrieved from this repository.

`git clone https://github.com/olcf/hip-training-series`

The exercises for this lecture are in the Lecture 4 directory. I have only 
had a quick test, so expect a few rough places. 

We are working with the portable build system from 
earlier exercises, so the tests on Perlmutter are
to run the Nvidia tools to get a profile there. An alternative that would
be good to try also is a portable HPC Community timeline profiling tool.
Comparing the results from these tools and between GPUs on a moderately 
complex problem would be worthy of a paper or report.

We focus on the AMD tools primarily because we don't want to speak for
our esteemed colleagues at Nvidia. They have the expertise on their
tools.

This markdown document is located at `'Lecture4/04 Performance_Timelines_Exercises.md'` contains 
the instructions to run the examples. You can view it in github for better readability or
download the pdf file `'Lecture4/04 Performance_Timelines_Exercises.pdf'` which has been
generated from the markdown document.

As is usual in this lecture series, the linked Google doc for comments, questions and answers
will be at https://docs.google.com/document/d/1aUfzofSgxCn-gkejJHDlh54YX5mRMaj5xkAO7zEZUkQ/edit

The reservation id for the schedule session is hip_training_2023_10_02.

\pagebreak{}

## Rocprof

In these examples, we'll first just try a simple example to make sure everything
is working. Then we'll add a more complex example with MPI.

### Simple HIP code

Get an allocation. Use your project id in the project field. If you do not remember it, 
run the command without the -A option and it should report your valid projects.
```
salloc -N 1 -n 2 -p batch --reservation=hip_training_2023_10_02 --gpus=2 -t 15:00 -A <project>
```

Get exercises
```
git clone https://github.com/olcf/hip-training-series
```
Go to first example
```
cd hip-training-series/Lecture4/saxpy
```

Load environment
```
module load PrgEnv-amd
module load amd
module load cmake
export CXX=${ROCM_PATH}/llvm/bin/clang++
```
Build saxpy application
```
make
```
Run application to make sure it is workig
```
./saxpy
```
It should report "PASSED!"

Run with rocprof
```
rocprof --stats ./saxpy
```
Check output from the stats report

```
cat results.stats.csv
```
You should see a report like:

```
"Name","Calls","TotalDurationNs","AverageNs","Percentage"
"saxpy(int, float const*, int, float*, int) [clone .kd]",1,4800,4800,100.0
```

But we want to focus on the timeline profile for these exercises.

```
rocprof --hip-trace --hsa-trace ./saxpy
```
Copy back to local system. From your local system:

```
scp frontier:hip-training-series/Lecture3/saxpy/results.json
```
Start up the chrome browser. Open the trace file

### A more complex code with MPI

We'll run a multi-process code to see a more complex timeline

Setup environment
```bash
salloc -N 1 -n 2 -p batch --reservation=hip_training_2023_10_02 --gpus=2 -t 15:00 -A <project>
module load rocm openmpi
```
Download examples repo and navigate to the `HIPIFY` exercises
```bash
cd hip-training-series/Lecture4/jacobi
```
Compile all
```bash
mkdir build && cd build
cmake ..
make
```
First run executable to check if running correctly
```
mpirun -n 2 ./Jacobi_hip -g 2
```
Run `rocprof` on jacobi to obtain trace files
```bash
mpirun -n 2 rocprof_wrapper.sh output ./Jacobi_hip -g 2
```
But we need a rocprof_wrapper.sh for creating separate files for the output. Here is one
for some versions of MPI. We'll cover how to modify it for other systems and MPI versions.

```
#!/bin/bash
set -euo pipefail
outdir=$1
name=$2
outdir=${outdir}_${OMPI_COMM_WORLD_RANK}
outfile="${name}_${OMPI_COMM_WORLD_RANK}.csv
rocprof -d ${outdir} --hsa-trace --hip-trace -o ${outdir}/${outfile} ./Jacobi_hip $3 $4
```
The key here is to have a different output file name and/or directory to feed into the
rocprof command. For a different MPI, run `mpirun -n 2 printenv` and see what environment
variable has the rank number in it. Substitute it for the `${OMPI_COMM_WORLD_RANK}` variable
above. Another option is to encode the process id into the strings with

```
pid=$$
outdir=${outdir}_${pid}
outfile="${name}_${pid}.csv
```

Check Results
```bash
cat results.csv
```
Check the statistics result file, one line per kernel, sorted in descending order of durations
```bash
cat results.stats.csv
```
Using `--basenames on` will show only kernel names without their parameters.
```bash
rocprof --stats --basenames on nbody-orig 65536
```
Check the statistics result file, one line per kernel, sorted in descending order of durations
```bash
cat results.stats.csv
```
Trace HIP calls with `--hip-trace`
```bash
rocprof --stats --hip-trace nbody-orig 65536
```
Check the new file `results.hip_stats.csv`
```bash
cat results.hip_stats.csv
```
Profile also the HSA API with the `--hsa-trace`
```bash
rocprof --stats --hip-trace --hsa-trace nbody-orig 65536
```
Check the new file `results.hsa_stats.csv`
```bash
cat results.hsa_stats.csv
```
On your laptop, download `results.json`
```bash
scp scp://USER@aac1.amd.com:<PORT>/~/HPCTrainingExamples/HIPIFY/mini-nbody/hip/results.json ./
```
Open a browser and go to [https://ui.perfetto.dev/](https://ui.perfetto.dev/).
Click on `Open trace file` in the top left corner.
Navigate to the `results.json` you just downloaded.
Use WASD to navigate the GUI

![image](https://user-images.githubusercontent.com/109979778/225451481-46ffd521-2453-4caa-8d28-fa4e0f4c4889.png)

Read about hardware counters available for the GPU on this system (look for gfx90a section)
```bash
less $ROCM_PATH/lib/rocprofiler/gfx_metrics.xml
```
Create a `rocprof_counters.txt` file with the counters you would like to collect
```bash
vi rocprof_counters.txt
```
Content for `rocprof_counters.txt`:
```bash
pmc : Wavefronts VALUInsts
pmc : SALUInsts SFetchInsts GDSInsts
pmc : MemUnitBusy ALUStalledByLDS
```
Execute with the counters we just added:
```bash
rocprof --timestamp on -i rocprof_counters.txt  nbody-orig 65536
```
You'll notice that `rocprof` runs 3 passes, one for each set of counters we have in that file.

Contents of `rocprof_counters.csv`
```bash
cat rocprof_counters.csv
```
```bash
exit
```

--------------------------------------------------------------

# Omnitrace

Setup environment
```bash
module load rocm openmpi
```
## Basic Omnitrace setup
List the various options and environment settings available for the `omnitrace` category:
```bash
omnitrace-avail --categories omnitrace
```
To add brief descriptions, use `-bd` option
```bash
omnitrace-avail -bd --categories omnitrace
```
Create an Omnitrace configuration file with description per option.
```bash
omnitrace-avail -G ~/omnitrace_all.cfg --all
```
To create a configuration file without descriptions, drop the `--all` option:
```bash
omnitrace-avail -G ~/omnitrace.cfg
```
Declare to use this configuration file:
```bash
export OMNITRACE_CONFIG_FILE=~/omnitrace.cfg
```

## Setup Jacobi Example

Go to the jacobi code in the examples repo:
```bash
cd ~/HPCTrainingExamples/HIP/jacobi
```
Compile
```bash
make
```
Execute the binary to make sure it runs successfully:
  - Note: To get rid of `Read -1, expected 4136, errno = 1` add `--mca pml ucx --mca pml_ucx_tls ib,sm,tcp,self,cuda,rocm` to the `mpirun` command line

```bash
mpirun -np 1 ./Jacobi_hip -g 1 1
```

## Dynamic Instrumentation
(WARNING) - this may in the current container
Run the code with omnitrace to get runtime instrumentation. Time it to see overhead of dyninst loading all libraries in the beginning.
```bash
mpirun -np 1 omnitrace-instrument -- ./Jacobi_hip -g 1 1
```
Check available functions to instrument using the `--print-available functions` option.
Note, the `--simulate` option will not execute the binary.
```bash
mpirun -np 1 omnitrace-instrument -v 1 --simulate --print-available functions -- ./Jacobi_hip -g 1 1
```

## Binary Rewrite
Create instrumented binary
```bash
omnitrace-instrument -o ./Jacobi_hip.inst -- ./Jacobi_hip
```
Executing the new instrumented binary, time it to see lower overhead:
```bash
mpirun -np 1 omnitrace-run -- ./Jacobi_hip.inst -g 1 1
```
See the list of the instrumented GPU calls:
```bash
cat omnitrace-Jacobi_hip.inst-output/<TIMESTAMP>/roctracer-0.txt
```

## Visualization
Copy the `perfetto-trace-0.proto` to your laptop, open the web page [https://ui.perfetto.dev/](https://ui.perfetto.dev/)
```bash
scp scp://USER@aac1.amd.com:<PORT>/~/HPCTrainingExamples/HIP/jacobi/omnitrace-Jacobi_hip.inst-output/TIMESTAMP/perfetto-trace-0.proto ./
```
Click `Open trace file` and select the `.proto` file

![image](https://user-images.githubusercontent.com/109979778/225769857-900aa6dd-1c7a-440f-82ab-872dcc09d73c.png)

## Hardware Counters
See a list of all the counters
```bash
omnitrace-avail --all
```
Declare in your configuration file:
```bash
OMNITRACE_ROCM_EVENTS = GPUBusy,Wavefronts,MemUnitBusy
```
Check again:
```bash
grep OMNITRACE_ROCM_EVENTS $OMNITRACE_CONFIG_FILE
```
Run the instrumented binary, and visualize the Perfetto trace produced to see the hardware counters:
```bash
mpirun -np 1 omnitrace-run -- ./Jacobi_hip.inst -g 1 1
```

## Profiling Multiple Ranks
Run the instrumented binary with multiple ranks. You'll find multiple `perfetto-trace-*.proto` files, one for each rank.
```bash
mpirun -np 2 omnitrace-run -- ./Jacobi_hip.inst -g 2 1
```
You can visualize them separately in Perfetto, or combine them using cat and visualize them in the same Perfetto window.
```bash
cat perfetto-trace-0.proto perfetto-trace-1.proto > allprocesses.proto
```

## Sampling

Set the following in your configuration file:
```bash
OMNITRACE_USE_SAMPLING = true
OMNITRACE_SAMPLING_FREQ = 100
```
Execute the instrumented binary and visualize the perfetto trace.
```bash
mpirun -np 1 omnitrace-run -- ./Jacobi_hip.inst -g 1 1
```
Scroll down to the very bottom to see the sampling output.
Those traces will be annotated with a (S) as well.

## Kernel Timings

Open the `wall_clock-0.txt` file:
```bash
cat omnitrace-Jacobi_hip.inst-output/<TIMESTAMP>/wall_clock-0.txt
```
In order to see the kernel durations aggregated in your configuration file, make sure to set in your config file or in the environment:
```bash
OMNITRACE_USE_TIMEMORY = true
OMNITRACE_FLAT_PROFILE = true
```
Execute the code and check the `wall_clock-0.txt` file again.
```bash
OMNITRACE_USE_TIMEMORY=true OMNITRACE_FLAT_PROFILE=true mpirun -np 1 omnitrace-run -- ./Jacobi_hip.inst -g 1 1
```

--------------------------------------------------------------

\pagebreak{}

# Omniperf

## vcopy

Setup environment
```bash
module load rocm openmpi
```
Get sample code
```bash
wget https://github.com/AMDResearch/omniperf/raw/main/sample/vcopy.cpp
```
Compile
```bash
hipcc -o vcopy vcopy.cpp
```

NOTE: THIS FAILS BECAUSE ROOFLINE CODE IS MISSING 

Profile with omniperf
```bash
omniperf profile -n vcopy_all -- ./vcopy 1048576 256
```
A new directory will be created named `workloads/vcopy_all`.

Analyze the collected profile using the built-in CLI
```bash
omniperf analyze -p workloads/vcopy_all/mi200/ &> vcopy_analyze.txt
```
View `vcopy_analyze.txt`
```bash
less vcopy_analyze.txt
```
We can select specific IP Blocks to analyze
```bash
omniperf analyze -p workloads/vcopy_all/mi200/ -b 7.1.2
```
If you've installed Omniperf on your laptop ( No ROCm Required ), you can
download `workloads/vcopy_all/mi200/` to your laptop and
run omniperf with `--gui` option
```bash
omniperf analyze -p workloads/vcopy_all/mi200/ --gui
```
Open the following in your browser
```url
http://172.21.7.117:8050/
```
![image](https://user-images.githubusercontent.com/109979778/225511493-c7cccc21-9cb8-426f-82da-7f790066aa89.png)

## dgemm

```
cd HPCTrainingExamples/dgemm

mkdir build && cd build
cmake ..
make
```
Profile and analyze code

```
omniperf profile -n dgemm -- ./dgemm
omniperf analyze -p workloads/dgemm/mi200 >& omniperf.out
less omniperf.out
```





# Disclaimer

The information presented in this document is for informational purposes only and may contain technical inaccuracies, omissions, and typographical errors. The information contained herein is subject to change and may be rendered inaccurate for many reasons, including but not limited to product and roadmap changes, component and motherboard version changes, new model and/or product releases, product differences between differing manufacturers, software changes, BIOS flashes, firmware upgrades, or the like. Any computer system has risks of security vulnerabilities that cannot be completely prevented or mitigated.  AMD assumes no obligation to update or otherwise correct or revise this information. However, AMD reserves the right to revise this information and to make changes from time to time to the content hereof without obligation of AMD to notify any person of such revisions or changes.

THIS INFORMATION IS PROVIDED "AS IS." AMD MAKES NO REPRESENTATIONS OR WARRANTIES WITH RESPECT TO THE CONTENTS HEREOF AND ASSUMES NO RESPONSIBILITY FOR ANY INACCURACIES, ERRORS, OR OMISSIONS THAT MAY APPEAR IN THIS INFORMATION. AMD SPECIFICALLY DISCLAIMS ANY IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, OR FITNESS FOR ANY PARTICULAR PURPOSE. IN NO EVENT WILL AMD BE LIABLE TO ANY PERSON FOR ANY RELIANCE, DIRECT, INDIRECT, SPECIAL, OR OTHER CONSEQUENTIAL DAMAGES ARISING FROM THE USE OF ANY INFORMATION CONTAINED HEREIN, EVEN IF AMD IS EXPRESSLY ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.

Third-party content is licensed to you directly by the third party that owns the content and is not licensed to you by AMD.  ALL LINKED THIRD-PARTY CONTENT IS PROVIDED "AS IS" WITHOUT A WARRANTY OF ANY KIND.  USE OF SUCH THIRD-PARTY CONTENT IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT.  YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THIRD-PARTY CONTENT.

© 2023 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, ROCm, Radeon, Radeon Instinct and combinations thereof are trademarks of Advanced Micro Devices, Inc. in the United States and/or other jurisdictions. Other names are for informational purposes only and may be trademarks of their

