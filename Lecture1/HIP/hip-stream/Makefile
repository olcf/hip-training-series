EXECUTABLE = ./stream
all: $(EXECUTABLE) test

.PHONY: test

OBJECTS = stream.o

CXXFLAGS = -g -O2 -DNDEBUG -fPIC
HIPCC_FLAGS = -g -O2 -DNDEBUG

HIPCC ?= hipcc
LD = hipcc
HIP_PATH ?= $(shell hipconfig --path)

ifeq ($(HIPCC), nvcc)
   HIPCC_FLAGS += -x cu -I${HIP_PATH}/include/
   LDFLAGS = -lcudadevrt -lcudart_static -lrt -lpthread -ldl
endif
ifeq ($(HIPCC), hipcc)
   HIPCC_FLAGS += -x hip -munsafe-fp-atomics
   LDFLAGS = -L${ROCM_PATH}/hip/lib -lamdhip64
endif

%.o: %.hip
	$(HIPCC) $(HIPCC_FLAGS) -c $^ -o $@

$(EXECUTABLE): $(OBJECTS)
	$(LD) $< $(LDFLAGS) -o $@

test: $(EXECUTABLE)
	$(EXECUTABLE)

clean:
	rm -rf $(EXECUTABLE) $(OBJECTS) build
