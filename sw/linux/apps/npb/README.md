# npb: NAS Parallel Benchmarks 3.3.1, OpenMP version

`NPB3.3-OMP/` is the unmodified NPB3.3-OMP source. The package builds, with the
Buildroot toolchain (`gfortran`/`gcc -fopenmp`, needs Fortran and OpenMP enabled
in `br_config`):

- `/usr/bin/npb/<bench>.<class>.x` for `NPB_BENCHMARKS` x `NPB_CLASSES` in
  [npb.mk](npb.mk) (currently `bt cg ep ft is lu mg sp` x `S W`, the NPB
  benchmarks of Bosbach et al., DAC 2024). The class is fixed at
  compile time by NPB's `setparams`, every class is its own binary.
- `/usr/bin/hclk`: prints the host wall clock (simdev `hclk` register).
- `/etc/init.d/S98npb`: if `/etc/npb_job` exists, runs that job in the
  foreground during boot, e.g.
  ```
  NPB_BENCH=cg.W
  OMP_NUM_THREADS=4
  ```
  and prints `NPB_HCLK_START` / `NPB_HCLK_END` / `NPB_EXIT` around it.
  Afterwards `S99hello_world` calls `simexit`. Without the job file the boot is
  unchanged.

The job file is written into a copy of `rootfs.ext4` from the host, e.g.
```
debugfs -w -R "write npb_job /etc/npb_job" rootfs-copy.ext4
```
vcml-pydrofoil's `benchmark/benchmark.py` (benchmark `linux_npb`) does this for
every run.

More benchmarks or classes: extend `NPB_BENCHMARKS` / `NPB_CLASSES` and rebuild
with `npb-dirclean all`. Mind the 512 MB RAM of the VP for larger classes.
