cmake_minimum_required(VERSION 3.12)
project(hclktime)

add_library(hclktime SHARED
    ${CMAKE_CURRENT_SOURCE_DIR}/hclktime.c
    ${CMAKE_CURRENT_SOURCE_DIR}/simdev.c
)
target_include_directories(hclktime PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
set_target_properties(hclktime PROPERTIES POSITION_INDEPENDENT_CODE ON)

install(TARGETS hclktime)
install(FILES setup.source_me DESTINATION ${CMAKE_INSTALL_PREFIX})
