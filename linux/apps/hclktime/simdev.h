/******************************************************************************
 *                                                                            *
 * Copyright 2026 Chiara Ghinami  Nils Bosbach                                *
 *                                                                            *
 * This software is licensed under the MIT license found in the               *
 * LICENSE file at the root directory of this source tree.                    *
 *                                                                            *
 *****************************************************************************/

#ifndef SIMDEV_H
#define SIMDEV_H

#include <inttypes.h>

extern uint64_t simdev_addr();
extern int simdev_init(uint64_t address, uint64_t size);
extern uint64_t hclk_us();
extern void stop_sim();

#endif
