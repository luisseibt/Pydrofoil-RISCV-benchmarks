# Buildroot-based Linux Image for RISC-V

This directory contains configuration files and scripts to build a Buildroot-based Linux image for a RISC-V simulator. Buildroot is a tool that automates the process of building Linux for embedded system platforms.

Linux login information:

user: root
password: root

## Quick Start
*Prerequisites*: podman or docker ([setup.sh](common/setup.sh) picks the one it can find)

1. Clone with Buildroot submodule (`--recurse-submodules`)
1. Build the project by running [build_linux.sh](linux/build_linux.sh)
1. Run on the simulator with `<simulator binary> -f images/<cfg name>.cfg`

[vcml-pydrofoil](https://github.com/CGhinami/vcml-pydrofoil/blob/main/README.md) is a compatible RISC-V simulator. In the corresponding GitHub folder, you can find more information on how to build it, configure it and run it.

## Repo Organization
| Directory | Description |
| --------- | ----------- |
| [common](common) | Container setup scripts | 
| [docs](docs) | Minimal documentation | 
| [apps](linux/apps) | Applications to be installed under /root |
| [bootcode](linux/bootcode) | A minimal bootloader |
| [files/config](linux/files/config) | Saved Buildroot and Linux configurations (backup that survives the build) |
| [files/dt](linux/files/dt) | Device Tree and Makefile to build it. |
| [files/patches](linux/files/patches) | Patches applied to the original kernel |
| [files/scripts](linux/files/scripts) | Setup files called by Buildroot's Makefile |
| [files/vp_config](linux/files/vp_config) | The simulator configuration files |

#### Setup scripts
* [setup.sh](common/setup.sh) checks which container is installed
* [build_linux.sh](linux/build_linux.sh) starts the build inside the container by calling [run_container](linux/files/scripts/run_container). After the first build, it also forces the rebuild
* [run_container](linux/files/scripts/run_container) builds or updates the container image and starts the Linux image build targeting toolchain, kernel, firmware, filesystem etc
* [post-build.sh](linux/files/scripts/post-build.sh) is run by Buildroot *after* all the packages are compiled and installed, but *before* Buildroot packs system binaries, libraries and custom apps into `rootfs.ext4` and `rootfs.tar`. We use it to compile and install custom apps. The path to this script is specified in [br_config](linux/files/config/br_config)
* [post-image.sh](linux/files/scripts/post-image.sh) is run by Buildroot after the build. We use this script to copy to the output folder the relevant files for the simulator configuration that do not depend on the build process (firmware, .cfg, filesystem, .dtb). The path to this script is specified in [br_config](linux/files/config/br_config)
* [br_menuconfig.sh](linux/br_menuconfig.sh) and [linux_menuconfig.sh](linux/linux_menuconfig.sh) copy the saved Buildroot and Linux configurations into the output directory, open the GUI to modify them and copy the new configurations back to [files/config](linux/files/config) as a backup. 
* [update_dtb.sh](linux/update_dtb.sh) recompiles the .dts files and places them directly under the output folder (`/images/buildroot`)

## Modify the configurations with menuconfig
To change the Buildroot configuration, run [br_menuconfig.sh](linux/br_menuconfig.sh). This configures the target CPU architecture, toolchain/compiler options, user packages (Busybox, Python, custom apps), bootloaders, rootfs type and so forth.

To change the Linux kernel configuration, run instead [linux_menuconfig.sh](linux/linux_menuconfig.sh). With this you can choose if you want to have, e.g., POSIX support, profiling and namespaces support, specific optimizations enabled (e.g., dead code and data elimination), the compiler optimization level etc.

After the changes are saved, you need to run the build and install steps again. For this to be effective, run [build_linux.sh](linux/build_linux.sh), which only targets the changed files, avoiding the recompilation of the toolchain, the applications, C libraries etc. <br/>
**DO NOT** edit the [files/config](linux/files/config) manually, use the [linux_menuconfig.sh](linux/linux_menuconfig.sh) script to do so

*Note*: Changing options of a package that is already built and not called `linux` requires `make <pkg>-rebuild` (`linux-rebuild` is not a system-wide "rebuild" command, and Buildroot does not provide this option!). Changing the architecture, toolchain or C library, or removing a package, requires a clean build (`rm -rf linux/build`).

## Adding a custom application

If you want to add your custom application to this project, you are highly encouraged to follow the existing folder structure.
In the current setup, the apps are configured as external packages. For Buildroot to recognize our applications as such, we have under [linux/apps](linux/apps):
* [external.desc](linux/apps/external.desc), only if present Buildroot accepts the directory as an external package
* [Config.in](linux/apps/Config.in), tells Buildroot where to find the menu choices for each app. This information is used for the menuconfig
* [external.mk](linux/apps/external.mk), tells Buildroot where to look for the apps `.mk` files.

The application folder should have (at least) the following files:
* Application sources. If the sources are C++ files, make sure you have the C++ support enabled in [br_menuconfig.sh](linux/br_menuconfig.sh)
* CMakeLists.txt to build and install the app
* `.mk` file to specify some configurations (e.g., the source files path in the host) and generate cmake files for the compilation

The application is a package and therefore can be enabled via [br_menuconfig.sh](linux/br_menuconfig.sh). Only when enabled, it is built by the Buildroot toolchain during the build process and installed in the path specified by its CMakeLists.txt. By default, the install location is set to `/usr/bin`. 

**IMPORTANT** If you *add* a new application, you can rebuild the image using [build_linux.sh](linux/build_linux.sh). <br/>
If you *modify* an existing application, run:
```
linux/files/scripts/run_container "-it -e FORCE_UNSAFE_CONFIGURE=1" \
  "make -C /app/buildroot O=/app/build <pkg name>-rebuild all"
```
If you *remove* the application, you need a clean build:
```
rm -rf <path to build>/build
linux/build_linux.sh
```

#### Launch the application manually
1. Wait until boot has finished and log in as root (pw: root)
1. If the application is not in `/usr/bin`, navigate to the location of the application once you get a shell (`#`).
1. Run the application

In the current project, you can try this out, e.g., by running the CoreMark and hello_world apps, installed under `/usr/bin`.

#### Launch the application automatically
If you'd like your application to automatically run, you can add an init script to the application folder.
During boot, the main initialization program (`/etc/init.d/rcS`) scans the `/etc/init.d/` folder for any file starting with `S[0-99]`. 
The number is used to define the order in which the scripts are executed. For user applications, numbers from 90 to 99 can be used. 
These scripts run right before the booting finishes and can launch your custom application.

To support this:
1. Add a script named `S[0-99]<app-name>` to your application folder
1. Add the installation "rules" in the application `.mk` file. Here, choose `etc/init.d/` as installation directory
1. Rebuild the Linux image

You can find an example of this setup in the [hello_world](linux/apps/hello_world/) folder

## Simulator Configuration
The minimum hardware to run Linux includes, besides the CPU and the RAM, a CLINT timer, the PLIC interrupt controller, a UART and a block device to hold the root filesystem. <br/>
Hardware and simulation-related properties can be configured using a `.cfg` file. Example of configuration files can be found under [vp_config](linux/files/vp_config/). The hardware configuration (addresses, IRQ map) has to match the [device tree](linux/files/dt/).
For an (almost) complete configuration file documentation, please refer to the [simulator github](https://github.com/CGhinami/vcml-pydrofoil/blob/main/README.md). <br/> 
In the specific case of Linux, the RAM must be configured to load the OpenSBI binary, the Linux image and the DTB: 
```
# the offset can be recovered from br_config
system.sram.images = <path to opensbi bin>@0x00000000 \
                     <path to the vmlinux bin>@0x00200000 \
                     <path to the .dtb>@0x02200000
```
Additionally, the physical address of the DTB must be placed in register `a1`, according to the RISC-V convention. The `.cfg` should also set the register `a0` to the hart ID, and the `pc` to wherever the first instruction to be executed sits (the start of OpenSBI): 
```
system.core.pc = 0x80000000
system.core.a0 = 0x0
system.core.a1 = 0x82200000
```
Normally, a boot ROM sets these registers, but our simulator does not have one.

Finally, the virtual disk must be initialized with the location of the filesystem:
```
system.virtio_blk.image    = ${dir}/rootfs.ext4
system.virtio_blk.readonly = false
```

