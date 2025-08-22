O   ?= .
CPP ?= cpp
DTC ?= dtc
NVDLA ?= 0

CPPFLAGS := -nostdinc -undef -x assembler-with-cpp

OBJ := ${O}/ror-vp.dtb

all: $(OBJ)

clean:
	$(RM) $(OBJ)

${O}/%.dtb: ${O}/%.dts
	@mkdir -p ${O}
	$(DTC) -I dts -O dtb -o $@ $<

.PHONY: all clean
.INTERMEDIATE: $(OBJ:dtb=dts)