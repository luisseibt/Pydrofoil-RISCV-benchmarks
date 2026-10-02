# RISC-V Baremetal Benchmarks

This directory contains configuration files and scripts to build various baremetal benchmarks for RISC-V 32 and 64 bit.

## Quick Start
*Prerequisites*: podman or docker ([setup.sh](scripts/setup.sh) picks the one it can find)

1. Clone with submodules (`--recurse-submodules`)
1. Build the project by running [run_container](scripts/run_container)
1. Generate your configuration file with [gen_config.sh](vp_config/gen_config.sh)
1. Run on the simulator with `<simulator binary> -f <path to generated cfg>.cfg`

For example, for the Dhrystone RV64 benchmark, the build and setup is:
```bash
cd baremetal
./scripts/run_container riscv_tests 64        # suite, arch, [gsf]
./vp_config/gen_config.sh riscv_tests dhrystone 64
<simulator binary> -f ./vp_config/dhrystone_64.cfg
```

## Repo Organization
| Directory | Description |
| --------- | ----------- |
| [embench_helper](embench_helper) | Files with syscalls stubs and a linker script |
| [embench_iot](embench_iot) | Submodule of the embench-iot test suite |
| [riscv_tests](riscv_tests) | Submodule of the riscv-tests test suite |
| [scripts](scripts) | Setup files to build the benchmarks |
| [vp_config](vp_config) | The simulator configuration files |
| `build/` | Generated build output (not tracked) |

## Build Options
The [run_container](scripts/run_container) script takes the following options:
* test suite name (embench_iot or riscv_tests)
* architecture type (32 or 64)
* global scale factor (for embench-iot)

The default configuration builds [riscv_tests](riscv_tests) for RV64.

## Simulator Configuration
Hardware and simulation-related properties can be configured using a `.cfg` file. A template of configuration files can be found under [vp_config](vp_config).
For an (almost) complete configuration file documentation, please refer to the [simulator github](https://github.com/CGhinami/vcml-pydrofoil/blob/main/README.md).
You can customize the `.cfg` template with the [gen_config.sh](vp_config/gen_config.sh), which takes the following options:
* test suite name (embench_iot or riscv_tests)
* name of the benchmark
* architecture type (32 or 64)
* quantum parameter (default: 10us)

For example, running `gen_config.sh riscv_tests dhrystone 32` produces the `dhrystone_32.cfg` file under [vp_config](vp_config).
