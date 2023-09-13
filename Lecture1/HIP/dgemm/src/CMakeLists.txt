# /***************************************************************************
#  Copyright (c) 2022, Advanced Micro Devices, Inc. All rights reserved.
# ***************************************************************************/

include_directories("${CMAKE_SOURCE_DIR}")
message("Running src/CMakeLists.txt...")

set(
  CMAKE_ARCHIVE_OUTPUT_DIRECTORY
  ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR}
)
set(
  CMAKE_LIBRARY_OUTPUT_DIRECTORY
  ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR}
)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY
  ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_BINDIR}
)

set(BINOUT dgemm)
set(LIBOUT dgemm_lib)

file(GLOB SOURCES "*.cpp")

set_source_files_properties(${SOURCES} PROPERTIES LANGUAGE ${GPU_RUNTIME})
set_source_files_properties(${SOURCES} PROPERTIES COMPILE_FLAGS "${HIPCC_FLAGS}")

add_library(${LIBOUT} ${SOURCES})
add_executable(${BINOUT} ${SOURCES})

target_include_directories(
  ${LIBOUT}
  PUBLIC
  ${HIPCC_FLAGS}
     ${CMAKE_CURRENT_LIST_DIR}
)

target_link_libraries(${BINOUT} LINK_PUBLIC ${hipblas_LIBRARIES})

# EOF
