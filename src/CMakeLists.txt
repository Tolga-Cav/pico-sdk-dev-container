add_executable(pico2_blink
    main.c
)

# Enable USB serial output, disable UART (so `printf` goes over USB CDC and
# shows up as a /dev/ttyACM* or COMx device you can open in the serial monitor)
pico_enable_stdio_usb(pico2_blink 1)
pico_enable_stdio_uart(pico2_blink 0)

target_link_libraries(pico2_blink
    pico_stdlib
)

# Create map/bin/hex/uf2 files in addition to the ELF
pico_add_extra_outputs(pico2_blink)
