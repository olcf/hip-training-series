BUILDDIR := build
PRODUCT := pennant

SRCDIR := src

HDRS := $(wildcard $(SRCDIR)/*.hh)
SRCS := $(wildcard $(SRCDIR)/*.cc)
OBJS := $(SRCS:$(SRCDIR)/%.cc=$(BUILDDIR)/%.o)
DEPS := $(SRCS:$(SRCDIR)/%.cc=$(BUILDDIR)/%.d)

HDRS += $(SRCDIR)/HydroGPU.hh
SRCS += $(SRCDIR)/HydroGPU.cu
OBJS += $(BUILDDIR)/HydroGPU.o
DEPS += $(BUILDDIR)/HydroGPU.d

BINARY := $(BUILDDIR)/$(PRODUCT)

CPPFLAGS := -I.

# begin compiler-dependent flags
#
# gcc flags:
#CXX := g++
#CXXFLAGS_DEBUG := -g
#CXXFLAGS_OPT := -O3
#CXXFLAGS_OPENMP := -fopenmp

# intel flags:
CXX := amdclang++
CXXFLAGS_DEBUG := -g
CXXFLAGS_OPT := -O3 
CXXFLAGS_OPENMP := -openmp

# pgi flags:
#CXX := pgCC
#CXXFLAGS_DEBUG := -g
#CXXFLAGS_OPT := -O3 -fastsse
#CXXFLAGS_OPENMP := -mp

# end compiler-dependent flags

HIPC := hipcc
HIPCFLAGS := 
HIPCFLAGS_DEBUG := -G -lineinfo
HIPCFLAGS_OPT := -O3

LD := $(CXX)
LDFLAGS_CUDA := -L$(HIP_INSTALL_PATH)/lib64 -lcudart
LDFLAGS := -L${ROCM_PATH}/hip/lib -lamdhip64

# select optimized or debug
CXXFLAGS := $(CXXFLAGS_OPT) $(CPPFLAGS)
HIPCFLAGS += $(HIPCFLAGS_OPT) $(CPPFLAGS)
#CXXFLAGS := $(CXXFLAGS_DEBUG) $(CPPFLAGS)
#HIPCFLAGS += $(HIPCFLAGS_DEBUG) $(CPPFLAGS)

# add openmp flags (comment out for serial build)
#CXXFLAGS += $(CXXFLAGS_OPENMP)
#LDFLAGS += $(CXXFLAGS_OPENMP)

all : $(BINARY)

-include $(DEPS)

$(BINARY) : $(OBJS)
	@echo linking $@
	$(maketargetdir)
	$(LD) -o $@ $^ $(LDFLAGS)

$(BUILDDIR)/%.o : $(SRCDIR)/%.cc
	@echo compiling $<
	$(maketargetdir)
	$(CXX) $(CXXFLAGS) $(CXXINCLUDES) -c -o $@ $<

$(BUILDDIR)/%.o : $(SRCDIR)/%.hip
	@echo compiling $<
	$(maketargetdir)
	@# unsetting of CPATH is needed to make hipcc and icpc
	@# play nicely together
	(CPATH=;$(HIPC) $(HIPCFLAGS) $(HIPCINCLUDES) -c -o $@ $<)

$(BUILDDIR)/%.d : $(SRCDIR)/%.cc
	@echo making depends for $<
	$(maketargetdir)
	@$(CXX) $(CXXFLAGS) $(CXXINCLUDES) -M $< | sed "1s![^ \t]\+\.o!$(@:.d=.o) $@!" >$@

$(BUILDDIR)/%.d : $(SRCDIR)/%.hip
	@echo making depends for $<
	$(maketargetdir)
	@$(HIPC) $(HIPCFLAGS) $(HIPCINCLUDES) -M $< | sed "1s![^ \t]\+\.o!$(@:.d=.o) $@!" >$@

define maketargetdir
	-@mkdir -p $(dir $@) > /dev/null 2>&1
endef

clean :
	rm -f $(BINARY) $(OBJS) $(DEPS)
