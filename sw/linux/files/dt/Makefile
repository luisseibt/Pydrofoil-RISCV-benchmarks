###############################################################################
#                                                                             #
# Copyright 2026 Chiara Ghinami  Nils Bosbach                                 #
#                                                                             #
# This software is licensed under the MIT license found in the                #
# LICENSE file at the root directory of this source tree.                     #
#                                                                             #
###############################################################################

O   ?= .
CPP ?= cpp
DTC ?= dtc

CPPFLAGS := -nostdinc -undef -x assembler-with-cpp

CPUS := 1 2 4

# The vcml-pydrofoil platform is single-hart, so it only gets an x1 variant.
PYDROFOIL_CPUS := 1

OBJ += $(addprefix ${O}/pydrofoil-vp-x,${PYDROFOIL_CPUS:=.dtb})

all: $(OBJ)

clean:
	$(RM) $(OBJ)

${O}/pydrofoil-vp-x%.dts: pydrofoil-vp.dts
	@mkdir -p ${O}
	$(CPP) $(CPPFLAGS) -D NRCPU=$* -o $@ $<

${O}/%.dtb: ${O}/%.dts
	@mkdir -p ${O}
	$(DTC) -I dts -O dtb -o $@ $<

.PHONY: all clean
.INTERMEDIATE: $(OBJ:dtb=dts)