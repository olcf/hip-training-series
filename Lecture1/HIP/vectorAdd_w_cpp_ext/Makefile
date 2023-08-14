EXECUTABLE = ./vectoradd
all: $(EXECUTABLE) test

.PHONY: test

OBJECTS = vectoradd.o

CXX=hipcc
CXXFLAGS = -g -O2 -DNDEBUG

HIP_PLATFORM ?= amd
HIP_PATH ?= $(shell hipconfig --path)

ifeq ($(HIP_PLATFORM), nvidia)
   CXXFLAGS += -x cu -I${HIP_PATH}/include/
   LDFLAGS = -lcudadevrt -lcudart_static -lrt -lpthread -ldl
endif
ifeq ($(HIP_PLATFORM), amd)
   CXXFLAGS += -x hip -munsafe-fp-atomics
   LDFLAGS = -L${ROCM_PATH}/hip/lib -lamdhip64
endif

$(EXECUTABLE): $(OBJECTS)
	hipcc $< $(LDFLAGS) -o $@

test: $(EXECUTABLE)
	$(EXECUTABLE)

clean:
	rm -rf $(EXECUTABLE) $(OBJECTS) build
