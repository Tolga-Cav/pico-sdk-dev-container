FROM mcr.microsoft.com/devcontainers/base:bookworm

# --- Build dependencies for the Pico SDK (Arm/Cortex-M33 toolchain) ---
# See: https://github.com/raspberrypi/pico-sdk
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y --no-install-recommends \
        cmake \
        ninja-build \
        build-essential \
        gcc-arm-none-eabi \
        libnewlib-arm-none-eabi \
        libstdc++-arm-none-eabi-newlib \
        python3 \
        python3-venv \
        git \
        pkg-config \
        gdb-multiarch \
        minicom \
        udev \
        usbutils \
        libusb-1.0-0-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# --- Fetch the Pico SDK (pinned to a known-good tag that supports RP2350/Pico 2) ---
ENV PICO_SDK_PATH=/opt/pico-sdk
RUN git clone -b 2.1.1 https://github.com/raspberrypi/pico-sdk.git ${PICO_SDK_PATH} \
    && cd ${PICO_SDK_PATH} && git submodule update --init --depth 1

# picotool is handy for inspecting/loading UF2s and reading device info
RUN git clone -b 2.1.1 --depth 1 https://github.com/raspberrypi/picotool.git /opt/picotool \
    && mkdir -p /opt/picotool/build && cd /opt/picotool/build \
    && cmake -G Ninja -DPICO_SDK_PATH=${PICO_SDK_PATH} .. \
    && ninja \
    && ninja install \
    && ldconfig

# Let the non-root "vscode" user (built into the base devcontainer image) access
# serial/USB devices passed into the container.
RUN usermod -aG dialout,plugdev vscode

USER vscode
WORKDIR /workspace
