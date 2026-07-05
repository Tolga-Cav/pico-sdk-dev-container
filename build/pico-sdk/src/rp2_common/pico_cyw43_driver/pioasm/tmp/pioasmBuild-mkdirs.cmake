# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

cmake_minimum_required(VERSION 3.5)

file(MAKE_DIRECTORY
  "/opt/pico-sdk/tools/pioasm"
  "/workspaces/pico-sdk-dev-container/build/pioasm"
  "/workspaces/pico-sdk-dev-container/build/pioasm-install"
  "/workspaces/pico-sdk-dev-container/build/pico-sdk/src/rp2_common/pico_cyw43_driver/pioasm/tmp"
  "/workspaces/pico-sdk-dev-container/build/pico-sdk/src/rp2_common/pico_cyw43_driver/pioasm/src/pioasmBuild-stamp"
  "/workspaces/pico-sdk-dev-container/build/pico-sdk/src/rp2_common/pico_cyw43_driver/pioasm/src"
  "/workspaces/pico-sdk-dev-container/build/pico-sdk/src/rp2_common/pico_cyw43_driver/pioasm/src/pioasmBuild-stamp"
)

set(configSubDirs )
foreach(subDir IN LISTS configSubDirs)
    file(MAKE_DIRECTORY "/workspaces/pico-sdk-dev-container/build/pico-sdk/src/rp2_common/pico_cyw43_driver/pioasm/src/pioasmBuild-stamp/${subDir}")
endforeach()
if(cfgdir)
  file(MAKE_DIRECTORY "/workspaces/pico-sdk-dev-container/build/pico-sdk/src/rp2_common/pico_cyw43_driver/pioasm/src/pioasmBuild-stamp${cfgdir}") # cfgdir has leading slash
endif()
