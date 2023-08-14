EXECUTABLE = ./saxpy
all: $(EXECUTABLE) test

.PHONY: test

OBJECTS = saxpy.o

CXXFLAGS = -g -O2 -DNDEBUG -fPIC
HIPCC_FLAGS = -g -O2 -DNDEBUG

HIP_PLATFORM ?= amd
HIP_PATH ?= $(shell hipconfig --path)

ifeq ($(HIP_PLATFORM), nvidia)
   HIPCC_FLAGS += -x cu -I${HIP_PATH}/include/
   LDFLAGS = -lcudadevrt -lcudart_static -lrt -lpthread -ldl
endif
ifeq ($(HIP_PLATFORM), amd)
   HIPCC_FLAGS += -x hip -munsafe-fp-atomics
   LDFLAGS = -L${ROCM_PATH}/hip/lib -lamdhip64
endif

%.o: %.hip
	hipcc $(HIPCC_FLAGS) -c $^ -o $@

$(EXECUTABLE): $(OBJECTS)
	hipcc $< $(LDFLAGS) -o $@

test: $(EXECUTABLE)
	$(EXECUTABLE)

clean:
	rm -rf $(EXECUTABLE) $(OBJECTS) build
