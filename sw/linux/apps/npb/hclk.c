/*
 * Prints the host wall clock of the simulation in microseconds, read from the
 * simdev's hclk register (vcml::meta::simdev, offset 0x20). The simdev is
 * found in the device tree like simexit does (compatible "sifive,test0").
 * Used by S98npb to time the benchmark itself, without the boot.
 */

#define _GNU_SOURCE
#include <dirent.h>
#include <fcntl.h>
#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>

#define DT_ROOT       "/proc/device-tree"
#define SIMDEV_COMPAT "sifive,test0"
#define REG_HCLK      0x20

static uint64_t get_simdev_base(void) {
    DIR *d = opendir(DT_ROOT);
    if (!d) return 0;

    struct dirent *e;
    uint64_t base = 0;
    while ((e = readdir(d))) {
        char path[256], buf[256];
        snprintf(path, sizeof(path), DT_ROOT "/%s/compatible", e->d_name);
        int fd = open(path, O_RDONLY);
        if (fd < 0) continue;
        ssize_t n = read(fd, buf, sizeof(buf));
        close(fd);

        if (n > 0 && memmem(buf, n, SIMDEV_COMPAT, sizeof(SIMDEV_COMPAT) - 1)) {
            snprintf(path, sizeof(path), DT_ROOT "/%s/reg", e->d_name);
            fd = open(path, O_RDONLY);
            if (fd >= 0) {
                uint32_t reg[2];
                if (read(fd, reg, sizeof(reg)) == sizeof(reg))
                    base = ((uint64_t)__builtin_bswap32(reg[0]) << 32) | __builtin_bswap32(reg[1]);
                close(fd);
            }
            break;
        }
    }
    closedir(d);
    return base;
}

int main(void) {
    uint64_t base = get_simdev_base();
    if (!base) {
        fprintf(stderr, "hclk: device '%s' not found\n", SIMDEV_COMPAT);
        return 1;
    }

    int fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (fd < 0) {
        perror("hclk: /dev/mem");
        return 1;
    }

    volatile uint8_t *regs = mmap(NULL, 4096, PROT_READ | PROT_WRITE, MAP_SHARED, fd, base);
    if (regs == MAP_FAILED) {
        perror("hclk: mmap");
        close(fd);
        return 1;
    }

    printf("%" PRIu64 "\n", *(volatile uint64_t *)(regs + REG_HCLK));
    return 0;
}
