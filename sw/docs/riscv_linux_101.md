# RISC-V Linux 101
Basic concepts on our Linux RISC-V image

## Really basic concepts before you read further
**Privilege levels**: On RISC-V, software runs at different privilege levels:
- M-mode (highest), the firmware runs here to do basic hardware setup
- S-mode (middle), the Linux kernel runs here
- U-mode (lowest), applications run here

**Virtual Addresses**: OSes use virtual memory addresses for at least 3 reasons: process isolation, memory fragmentation and page swapping. The MMU makes the translation from virtual to physical addresses possible. The MMU first checks a fast internal cache, called Translation Lookaside Buffer (TLB). If the mapping is cached, then there is a TLB hit. If there is a miss, the MMU has to navigate the three or four levels of page table to calculate the final physical address. This process is called Page Table Walk. This is always needed when the CPU is executing in S-mode or U-mode. In M-mode, special rules apply. M-mode code is strictly designed to operate on physical addresses. For example, the firmware runs in M-mode and, while it runs, the address translation (MMU) is not active and the addresses reference physical memory directly. If code executing in M-mode uses the virtual memory (e.g., if the address is provided by software running in S-mode) the mstatus register is updated (field MPRV) to temporarily modify the privilege and run the memory instruction in S-mode, which benefits from the MMU translation.

**Address Space Layout Randomization**: To ensure process isolation, each user-space process gets its own private memory layout. By default, an application is compiled as *PIE* (Position Independent Executable). This means that the virtual location of the executable is not hardcoded into the binary. This makes possible the usage of *ASLR* (Address Space Layout Randomization). ASLR makes sure that a different virtual address is assigned to each process when created, it is a security feature that makes it difficult for a potential attacker to successfully guess processes virtual addresses. If the application instead is compiled without position-independent code support (non-PIE), each process has by default the same virtual address, each mapped to a different physical address to prevent clashes.

**Process Page Table**: A Process Page Table is a multi-level data structure created by the OS specifically for an individual user process to translate that process's private virtual addresses into physical RAM addresses. When an instruction with a virtual address must be executed, the physical address of the process page table is read. This address, together with the process virtual address, is used to calculated the final physical address. This is a multi-step process: at each step, a different page table entry is identified. For example, in the first step the page table entry is calculated as $PA_{root} + (VA[38-30] \times 8 bytes)$, where $PA_{root}$ identifies the correct page, $VA[38-30] \times 8 bytes$ identifies the index within the page multiplied by the size of each entry.

**Device Tree**: A device tree is a file that describes physical hardware layout so an OS can understand and interact with a board without hard-coding those details into its kernel. It is usually organized as a hierarchical tree of named nodes (representing devices or IP blocks). In its readable format, it is a .dts file, while a .dtb represents a Device Tree Blob (DTB), which is the compiled version of a .dts parsed by the OS at boot.

## Linux Boot and OpenSBI
The Supervisor Binary Interface (SBI) is an API that defines the convention that Linux, in S-mode, uses to call the firmware, in M-mode. This standard specification is maintained by RISC-V International. OpenSBI is an open-source implementation of the SBI standard and runs entirely in M-mode.

In this context, OpenSBI:
1. Boots in M-mode, configures the Physical Memory Protection (PMP), if present, and takes care of trap delegation. The delegation allows S-mode software to handle interrupts and exceptions instead of switching priviledge when traps happen to let M-mode firmware handle them.
1. Loads the hart ID into register **a0** and copies the physical dbt address to register **a1** 
1. Fakes an exception return forcing the address to be the entry point of Linux kernel. This happens in 3 steps: it sets mstatus.MPP to 1 (supervisor mode), it copies the kernel entry address to the mpec register (Machine Exception Program Counter) and executes the mret (Machine Exception and Return) instruction to jump to that address and launch Linux.

## Memory Layout
At the start of the physical RAM is loaded OpenSBI, then (not necessarely in this particular order) the Linux Kernel, the DTB and the Contiguous Memory Allocator (CMA), blocks used by device drivers that require contiguous chunks of memory. All the remaining RAM is managed dynamically by Linux for user applications, page tables etc. All of these can be accessed by the kernel via direct mapping, meaning that the physical address can be calculated from the virtual address by using a constant ($PA = VA - kof$).
The kernel benefits from the direct mapping because the translation is instant, O(1). This does not mean that it can avoid using the MMU, in S-mode the MMU is always on, but the address lookup itself is simpler and faster. 

```
Physical RAM                                  
+-------------------------------------+ 
| Firmware (OpenSBI)                  |       Virtual Address Space
+-------------------------------------+       +-------------------------------------+
| Kernel (.text, .rodata, .data, .bss)|  -->  |  Kernel space                       |
+-------------------------------------+       |                                     |
| DTB                                 |  -->  |                                     |
+-------------------------------------+       |                                     |
| CMA                                 |       |                                     |
+-------------------------------------+       |                                     |
|                                     |  -->  |                                     |
| Dynamic RAM Pool                    |       +-------------------------------------+
|                                     |  -->  |   User space                        |
+-------------------------------------+       +-------------------------------------+
```
#### Double mappings
Some components in the physical memory have *double mappings*, this is the case of the kernel code (.text). This means that it resides in the so called *lowmem*, and ALSO mapped at the very beginning of the VA. The reason for this is that the lowmem must be writable (RW), but normally the code to be executed should have different permissions, namely Executable (X) and Read-Only (RO). During normal operation, the "higher" mapping is used, while for special cases, for example when the kernel has to modify its own code, the lowmem is used. For BOTH cases the direct mapping holds.

Another case where the double mapping applies is for blocks allocated with `vmalloc()`. `vmalloc()` is a functionality used by the kernel for example when it needs to load kernel modules (.ko). Those are usually big, which means that they have to be scattered across the physical memory, but, as usual, their addresses have to appear contiguous. The physical pages that hold the modules will maintain their lowmem mapping, which is permanent, but those pages will also have another, contiguous virtual address range. Given the complexity required by `vmalloc()`, it is not the default choice of the kernel to dynamically allocate memory. Its direct-mapped counterpart is `kmalloc()`, which allocates memory that is contiguous in both physical and virtual address spaces and it is thus the faster option.
```
Dynamic RAM Pool:                           Vmalloc space:
+-------------------------------------+     +-------------------------------------+
| Page 1 (allocated)                  | --> | Page 1 VA                           |
|                                     |     | Page 3 VA                           |
| Page 2 (free)                       |     +-------------------------------------+
| Page 3 (allocated)                  |     lowmem:
+-------------------------------------+     +-------------------------------------+
                                            | Page 1 VA                           |
                                            | Page 2 VA                           |
                                            | Page 3 VA                           |
                                            +-------------------------------------+
```
#### User Space
Before spawning a process, the kernel selects a free page frame from the Dynamic RAM Pool. Since it already has a direct mapping of the whole RAM, it can access it directly and it zeros it to remove stale data (without the initial mapping, it would first have to create a VA for the selected frames). It then creates the Process Page Table for the new application and assigns a (second) VA to the process (the first VA remains the direct map). The start of the VA, together with the end of the process VA and page protection flags, are managed by the kernel and stored in Virtual Memory Area (VMA) kernel structures.
To ensure full process isolation, the process can access its virtual address range, and request changes or view information via system calls. The interaction between the kernel and the user-space process famously happens with system calls (`ecall` on RISC-V): before the ecall runs, the program counter is set to a user space VA (e.g., `0x10000`), when the ecall executes, the privilege level is set to S-mode and the program counter is changed to point at the system call entry point. For syscalls such as read() and write(), the kernel needs to access process data, not directly mapped. The address of this data is passed by the syscalls themselves, but by default the MMU blocks an S-mode access to data (or better, pages) marked as U-mode. This is solved via `copy_to_user()`: the Supervisor User Memory access (SUM) bit in sstatus register is set, the function `copy_to_user()` is executed and the process data is accessed using the address passed by the syscall.

## Self-modifying Code
Self-modifying code occurs whenever a running program alters its own machine instructions in memory before the CPU fetches and executes them. It is mostly used in the following cases:
1. **Early boot kernel instruction patching**: the kernel compiler generates placeholder code surrounded by special metadata sections in the binary, named `.altinstructions`. During boot, the kernel overwrites the generic instructions directly in RAM with optimized CPU-specific instructions. For example, if the specific RISC-V CPU the kernel is running on supports vector extensions, generic instructions are replaced with RVV extensions. This eliminates runtime if/else checks in kernel code.
1. **Dynamic tracing**: Ftrace is an internal tracing framework built directly into the Linux kernel to debug what is happening inside kernel. This mechanism heavily uses self-modifying code. At compile time, if tracing flags are specified (`-mfentry` or `-pg`) calling instructions are inserted at the beginning of every kernel function. During booting, each of this call is replaced by a `NOP` operation to avoid slowdowns. Once the booting is completed and the tracing is enabled, ftrace replaces the NOPs once again with active calls.
1. **Static keys** (or jump_label): Normally, a standard `if(variable)` statement requires the CPU to load the variable from memory, test its value, and conditionally branch based on the result. If it is almost always enabled (or disabled), executing this check every single time wastes time. When a *key* (variable) is defined with `DEFINE_STATIC_KEY_TRUE(key)`, the compiler generates the code assuming the branch is taken. Otherwise, if the branch will likely be non-taken, a `NOP` replaces the entry point (the if condition). If the state of the key needs to change during runtime, the kernel dynamically patches the running binary text. IThe goal is similar to ftrace's: rewriting the kernel's binary instructions in memory at runtime to eliminate conditional branching overhead. The kernel keeps track of them using a special internal lookup table called `__jump_table`. It is fully generated at compiled time and stores, among other things, the precise address of the code instruction being modified.

*Note*: Other (less known) cases for self-modifying code include digital rights management (DRM) software and UPX-packed executables, kprobes and kgdb breakpoints for debugging.