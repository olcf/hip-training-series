#!/bin/sh
module load PrgEnv-amd
module load amd/5.5.1
module load cmake
export CXX=${ROCM_PATH}/llvm/bin/clang++

rm -rf ~/hip-training-series/Lecture2/HIPIFY/Pennant-new
mkdir ~/hip-training-series/Lecture2/HIPIFY/Pennant-new
cp -r ~/hip-training-series/Lecture2/HIPIFY/Pennant-orig/* ~/hip-training-series/Lecture2/HIPIFY/Pennant-new
cd  ~/hip-training-series/Lecture2/HIPIFY/Pennant-new
../hipconvertinplace-perl.sh .
rm -f src/*.prehip
mv src/HydroGPU.cu src/HydroGPU.hip

sed -i -e 's/CUDACFLAGS/HIPCFLAGS/g' Makefile
sed -i -e 's/CUDA/HIP/g' Makefile
sed -i -e '/CXX/s/icpc/amdclang++/' Makefile
sed -i -e 's/nvcc/hipcc/' Makefile
sed -i -e 's/-fast -fno-alias//' Makefile
sed -i -e 's/%.cu/%.hip/g' Makefile
sed -i -e 's/-arch=sm_21 --ptxas-options=-v//' Makefile
sed -i -e 's/^LDFLAGS/LDFLAGS_CUDA/' Makefile
sed -i -e '/^LDFLAGS_CUDA/aLDFLAGS := -L${ROCM_PATH}/hip/lib -lamdhip64' Makefile

sed -i -e 's/#ifndef __CUDACC__/#ifndef __HIPCC__/' src/Vec2.hh
sed -i -e 's/#ifdef __CUDACC__/#ifdef __HIPCC__/' src/Vec2.hh
sed -i -e '85,85s/#else/#elif defined\(__CUDACC__\)/' src/Vec2.hh

sed -i -e '724,724a#ifdef __CUDACC__' -e '738,738a#endif' src/HydroGPU.hip

sed -i -e '38,39s/const double2/const void/' src/HydroGPU.hh
sed -i -e '62,62s/double2/void/' src/HydroGPU.hh

sed -i -e '1031,1032s/const double2/const void/' src/HydroGPU.hip
sed -i -e '1284,1284s/double2/void/' src/HydroGPU.hip

sed -i -e '59,59s/mesh/(void *)mesh/' src/Hydro.cc
sed -i -e '60,60s/pu/(void *)pu/' src/Hydro.cc
sed -i -e '145,145s/mesh/(void *)mesh/' src/Hydro.cc

make

build/pennant test/sedovbig/sedovbig.pnt
rm -rf build
make clean

echo ""
echo ""
echo ""
echo ""
echo ""
echo " Portable Makefile build system"
echo ""

cp ../Makefile.new .

make
build/pennant test/sedovbig/sedovbig.pnt
rm -rf build
make clean

echo ""
echo ""
echo ""
echo ""
echo ""
echo " CMake portable build system"
echo ""

cp ../CMakeLists.txt .
rm -rf build
mkdir build && cd build
cmake ..
make
./pennant ../test/sedovbig/sedovbig.pnt
cd ..
rm -rf build
