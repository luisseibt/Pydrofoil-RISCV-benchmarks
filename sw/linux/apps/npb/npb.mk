################################################################################
#
# npb: NAS Parallel Benchmarks 3.3.1, OpenMP version
#
################################################################################

NPB_VERSION = 3.3.1
NPB_SITE = $(BR2_EXTERNAL_RISCV_APPS_PATH)/npb
NPB_SITE_METHOD = local

# The NPB benchmarks of Bosbach et al., DAC 2024 (all but UA and DC). IS is C,
# the others Fortran. Every class is a separate binary
# (the problem size is fixed at compile time by NPB's setparams).
NPB_BENCHMARKS = bt cg ep ft is lu mg sp
NPB_CLASSES = S W

NPB_SRC = $(@D)/NPB3.3-OMP

# setparams runs on the build host (UCC), the benchmarks on the target.
# -fallow-invalid-boz / -fallow-argument-mismatch: NPB's Fortran 77 (X'..'
# hex constants etc.) is rejected by gfortran >= 10 otherwise.
define NPB_MAKE_DEF
	printf '%s\n' \
		'F77 = $(TARGET_FC)' \
		'FLINK = $$(F77)' \
		'FFLAGS = -O3 -fopenmp -fallow-invalid-boz -fallow-argument-mismatch' \
		'FLINKFLAGS = -O3 -fopenmp' \
		'F_LIB =' \
		'F_INC =' \
		'CC = $(TARGET_CC)' \
		'CLINK = $$(CC)' \
		'CFLAGS = -O3 -fopenmp' \
		'CLINKFLAGS = -O3 -fopenmp' \
		'C_LIB = -lm' \
		'C_INC =' \
		'UCC = $(HOSTCC)' \
		'BINDIR = ../bin' \
		'RAND = randi8' \
		'WTIME = wtime.c' \
		> $(NPB_SRC)/config/make.def
endef

define NPB_BUILD_CMDS
	$(NPB_MAKE_DEF)
	mkdir -p $(NPB_SRC)/bin
	for bench in $(NPB_BENCHMARKS); do \
		for class in $(NPB_CLASSES); do \
			BENCH=$$(echo $$bench | tr a-z A-Z); \
			$(MAKE1) -C $(NPB_SRC)/$$BENCH clean && \
			$(MAKE1) -C $(NPB_SRC) $$bench CLASS=$$class || exit 1; \
		done; \
	done
	$(TARGET_CC) -O2 -o $(@D)/hclk $(@D)/hclk.c
endef

define NPB_INSTALL_TARGET_CMDS
	for bin in $(NPB_SRC)/bin/*.x; do \
		$(INSTALL) -D -m 0755 $$bin $(TARGET_DIR)/usr/bin/npb/$$(basename $$bin) || exit 1; \
	done
	$(INSTALL) -D -m 0755 $(@D)/hclk $(TARGET_DIR)/usr/bin/hclk
endef

define NPB_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 $(NPB_PKGDIR)/S98npb $(TARGET_DIR)/etc/init.d/S98npb
endef

$(eval $(generic-package))
