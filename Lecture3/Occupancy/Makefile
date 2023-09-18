EXECUTABLE = ./occupancy_mxv
all: $(EXECUTABLE)

.PHONY: test

OBJECTS = occupancy_mxv.o

CXX=hipcc
CXXFLAGS = -g -O2 -DNDEBUG

HIP_PLATFORM ?= amd

ifeq ($(HIP_PLATFORM), nvidia)
   HIP_PATH ?= $(shell hipconfig --path)
   CXXFLAGS += -x cu -I${HIP_PATH}/include/
endif
ifeq ($(HIP_PLATFORM), amd)
   CXXFLAGS += -x hip -munsafe-fp-atomics
   #CXXFLAGS += -x hip -munsafe-fp-atomics -Rpass-analysis=kernel-resource-usage
endif

$(EXECUTABLE): $(OBJECTS)
	hipcc $< $(LDFLAGS) -o $@

test: $(EXECUTABLE)
	$(EXECUTABLE)

clean:
	rm -rf $(EXECUTABLE) $(OBJECTS) build
