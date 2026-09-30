/******************************************************************************
 *                                                                            *
 * Copyright 2026 Chiara Ghinami  Nils Bosbach                                *
 *                                                                            *
 * This software is licensed under the MIT license found in the               *
 * LICENSE file at the root directory of this source tree.                    *
 *                                                                            *
 *****************************************************************************/

#include "simdev.h"

#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <unistd.h>

struct simdev {
  volatile uint8_t *base;
  uint64_t address;
  uint64_t size;
  int fd;
  int init;
} simdev_instance;

uint64_t simdev_addr() {
  static const uint64_t DEFAULT_ADDR = 0x00100000;
  const char *env = getenv("SIMDEV_BASE");
  if (!env)
    return DEFAULT_ADDR;

  char *endptr = NULL;
  uint64_t val = strtoul(env, &endptr, 0);
  if (endptr == env || *endptr != '\0')
    return DEFAULT_ADDR;

  return val;
}

int simdev_init(uint64_t address, uint64_t size) {
  if (simdev_instance.init)
    return 0;

  simdev_instance.address = address;
  simdev_instance.size = size;

  int fd = open("/dev/mem", O_RDWR | O_SYNC);
  if (fd < 0) {
    fprintf(stderr, "open failed\n");
    return 1;
  }
  simdev_instance.fd = fd;

  void *map_base =
      mmap(NULL, simdev_instance.size, PROT_READ | PROT_WRITE, MAP_SHARED,
           simdev_instance.fd, simdev_instance.address);
  if (map_base == MAP_FAILED) {
    fprintf(stderr, "mmap failed\n");
    close(fd);
    return 1;
  }
  simdev_instance.base = (uint8_t *)map_base;
  simdev_instance.init = 1;
  return 0;
}

uint64_t hclk_us() {
  if (!simdev_instance.init)
    return 0;

  return *((uint64_t *)(simdev_instance.base + 0x20));
}


void stop_sim() {
  if (!simdev_instance.init)
    return;

  *((uint64_t *)(simdev_instance.base + 0x00)) = 0x01;
}
