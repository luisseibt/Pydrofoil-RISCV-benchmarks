
#define _GNU_SOURCE
#include "simdev.h"
#include <dlfcn.h>
#include <stdint.h>
#include <stdio.h>
#include <time.h>

void __attribute__((constructor)) setup(void) {
  simdev_init(simdev_addr(), 0x1000);
}

void __attribute__((destructor)) end(void) {
  simdev_init(simdev_addr(), 0x1000);
}

time_t time(time_t *t) {
  static time_t (*real_time)(time_t *) = NULL;
  if (!real_time) {
    real_time = dlsym(RTLD_NEXT, "time");
    if (!real_time) {
      fprintf(stderr, "Failed to find original time function\n");
      return -1;
    }
  }

  uint64_t time_s = hclk_us() / 1000000;
  if (t) *t = time_s;
  return time_s;
}

int clock_gettime(clockid_t c, struct timespec *p) {
  static int (*real_clock_gettime)(clockid_t, struct timespec *) = NULL;
  if (!real_clock_gettime) {
    real_clock_gettime = dlsym(RTLD_NEXT, "time");
    if (!real_clock_gettime) {
      fprintf(stderr, "Failed to find original clock_gettime function\n");
      return -1;
    }
  }

  if (c != CLOCK_REALTIME)
    return real_clock_gettime(c, p);

  uint64_t time_us = hclk_us();
  p->tv_sec = time_us / 1000000;
  p->tv_nsec = (time_us - p->tv_sec * 1000000) * 1000;

  return 0;
}
