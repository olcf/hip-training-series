#!/bin/bash
set -euo pipefail
outdir=$1
name=$2
outdir="${outdir}_${OMPI_COMM_WORLD_RANK}"
outfile="${name}_${OMPI_COMM_WORLD_RANK}.csv"
rocprof -d ${outdir} --hsa-trace --hip-trace -o ${outdir}/${outfile} ./Jacobi_hip $3 $4
