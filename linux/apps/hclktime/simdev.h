#ifndef SIMDEV_H
#define SIMDEV_H

#include <inttypes.h>

extern uint64_t simdev_addr();
extern int simdev_init(uint64_t address, uint64_t size);
extern uint64_t hclk_us();

#endif
