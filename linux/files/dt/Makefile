O   ?= .
CPP ?= cpp
DTC ?= dtc

CPPFLAGS := -nostdinc -undef -x assembler-with-cpp

OBJ := ${O}/ror-vp-x1.dtb ${O}/ror-vp-x2.dtb

all: $(OBJ)

clean:
	$(RM) $(OBJ)

${O}/ror-vp-x1.dts: ror-vp.dts
	@mkdir -p ${O}
	$(CPP) $(CPPFLAGS) -D NRCPU=1 -o $@ $<

${O}/ror-vp-x2.dts: ror-vp.dts
	@mkdir -p ${O}
	$(CPP) $(CPPFLAGS) -D NRCPU=2 -o $@ $<

${O}/%.dtb: ${O}/%.dts
	@mkdir -p ${O}
	$(DTC) -I dts -O dtb -o $@ $<

.PHONY: all clean
.INTERMEDIATE: $(OBJ:dtb=dts)