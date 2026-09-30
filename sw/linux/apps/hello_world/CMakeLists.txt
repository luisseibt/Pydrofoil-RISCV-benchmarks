cmake_minimum_required(VERSION 3.12)
project(hello_world C) # Without C CMake assumes C++

add_executable(hello_world ${CMAKE_CURRENT_SOURCE_DIR}/hello_world.c)
add_executable(simexit simexit.c)

target_include_directories(hello_world PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

install(TARGETS hello_world)
install(TARGETS simexit)
