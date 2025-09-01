O   ?= .
CPP ?= cpp
DTC ?= dtc

CPPFLAGS := -nostdinc -undef -x assembler-with-cpp

CPUS := 1 2 4

OBJ := $(addprefix ${O}/ror-vp-x,${CPUS:=.dtb})

all: $(OBJ)

clean:
	$(RM) $(OBJ)

${O}/ror-vp-x%.dts: ror-vp.dts
	@mkdir -p ${O}
	$(CPP) $(CPPFLAGS) -D NRCPU=$* -o $@ $<

${O}/%.dtb: ${O}/%.dts
	@mkdir -p ${O}
	$(DTC) -I dts -O dtb -o $@ $<

.PHONY: all clean
.INTERMEDIATE: $(OBJ:dtb=dts)