cmake_minimum_required(VERSION 3.13)

# Pull in the SDK (must happen before project())
include(pico_sdk_import.cmake)

project(pico2_project C CXX ASM)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

# Initialize the Raspberry Pi Pico SDK
pico_sdk_init()

add_subdirectory(src)
