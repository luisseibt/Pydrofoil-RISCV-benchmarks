###############################################################################
#                                                                             #
# Copyright 2026 Chiara Ghinami  Nils Bosbach                                 #
#                                                                             #
# This software is licensed under the MIT license found in the                #
# LICENSE file at the root directory of this source tree.                     #
#                                                                             #
###############################################################################

cmake_minimum_required(VERSION 3.12)
project(hclktime)

add_library(hclktime SHARED
    ${CMAKE_CURRENT_SOURCE_DIR}/hclktime.c
    ${CMAKE_CURRENT_SOURCE_DIR}/simdev.c
)
target_include_directories(hclktime PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
# This is unnecessary, because CMake turns it on automatically for SHARED libraries
# set_target_properties(hclktime PROPERTIES POSITION_INDEPENDENT_CODE ON)

install(TARGETS hclktime)
install(FILES setup.source_me DESTINATION ${CMAKE_INSTALL_PREFIX})
