/******************************************************************************
 *                                                                            *
 * Copyright 2026 Chiara Ghinami  Nils Bosbach                                *
 *                                                                            *
 * This software is licensed under the MIT license found in the               *
 * LICENSE file at the root directory of this source tree.                    *
 *                                                                            *
 *****************************************************************************/

/*
 * This is an old application to overwrite the time() and clock_gettime() Linux functions
 * Nor properly tested, do not count on it for anything :)
 */


#define _GNU_SOURCE
#include "simdev.h"
#include <dlfcn.h>
#include <stdint.h>
#include <stdio.h>
#include <time.h>

// Run when the library is loaded
void __attribute__((constructor)) setup(void) {
  simdev_init(simdev_addr(), 0x1000);
}

// Executed AFTER the application when the library is unloaded via dlclose()
// Is this supposed to call stop_sim() rather than the init?
void __attribute__((destructor)) end(void) {
  simdev_init(simdev_addr(), 0x1000);
}

time_t time(time_t *t) {
  uint64_t time_s = hclk_us() / 1000000;
  if (t) *t = time_s;
  return time_s;
}

// Whenever the application wants the CLOCK_REALTIME (System-wide wall-clock time)
// return wall-clock time from the simulation clock
int clock_gettime(clockid_t c, struct timespec *p) {
  static int (*real_clock_gettime)(clockid_t, struct timespec *) = NULL;
  if (!real_clock_gettime) {
    real_clock_gettime = dlsym(RTLD_NEXT, "clock_gettime");
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
