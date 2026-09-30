#define _GNU_SOURCE
#include <dirent.h>
#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>

#define DT_ROOT       "/proc/device-tree"
#define SIMDEV_COMPAT "sifive,test0"
#define REG_STOP      0x00

// TODO check if this affects runtime speed
// This might also be merged with hclktime simdev.c
static uint64_t get_simdev_base(void) {
    // the Linux kernel exposes the DT to user space as a virtual directory hierarchy
    // when in reality it is a binary data structure, but thanks to the kernel we can
    // inspect it using file operations
    DIR *d = opendir(DT_ROOT);
    if (!d) return 0;

    struct dirent *e; // dirent: used to inspect files inside a directory
    uint64_t base = 0;

    // iteration through the contents of an open directory one entry at a time
    while ((e = readdir(d))) {
        char path[256], buf[256];

        // Check if node has matching compatible string
        snprintf(path, sizeof(path), DT_ROOT "/%s/compatible", e->d_name);
        int fd = open(path, O_RDONLY);
        if (fd < 0) continue;
        ssize_t n = read(fd, buf, sizeof(buf));
        close(fd);

        // if we have a compatible string, check if the node is SIMDEV
        if (n > 0 && memmem(buf, n, SIMDEV_COMPAT, sizeof(SIMDEV_COMPAT) - 1)) {
            // Read address cells, e.g., reg = <0x0 0x00100000 0x0 0x1000>
            snprintf(path, sizeof(path), DT_ROOT "/%s/reg", e->d_name);
            fd = open(path, O_RDONLY);

            if (fd >= 0) {
                uint32_t reg[2]; // reg[0] = 0x0, reg[1] = 0x00100000 ...
                // reg[0] represents the upper 32 bits, reg[1] the lower 32 bits of the addr
                // bswap32 is used to match the endianness of the CPU (regs are stored as big-endians)
                if (read(fd, reg, sizeof(reg)) == sizeof(reg)) {
                    base = ((uint64_t)__builtin_bswap32(reg[0]) << 32) | __builtin_bswap32(reg[1]);
                }
                close(fd);
            }
            break;
        }
    }
    closedir(d);
    return base;
}

int main(int argc, char **argv) {
    uint64_t base = get_simdev_base();
    if (!base) {
        fprintf(stderr, "simexit: device '%s' not found\n", SIMDEV_COMPAT);
        return 1;
    }

    int fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (fd < 0) {
        perror("simexit: /dev/mem");
        return 1;
    }

    // Map a standard 4KB page (sufficient for MMIO registers)
    volatile uint8_t *regs = mmap(NULL, 4096, PROT_READ | PROT_WRITE, MAP_SHARED, fd, base);
    if (regs == MAP_FAILED) {
        perror("simexit: mmap");
        close(fd);
        return 1;
    }

    sync(); // flush filesystem before simulator shuts down
    *(volatile uint64_t *)(regs + REG_STOP) = 1;

    return 0;
}