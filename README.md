# Pico 2 (RP2350) Dev Container

A ready-to-use VS Code Dev Container for building C/C++ firmware for the
Raspberry Pi Pico 2 (RP2350) with the official Pico SDK, CMake, and Ninja.

Flashing is done via **UF2 drag-and-drop** (BOOTSEL mode) and serial output
is read via **USB CDC serial**.

---

## 1. How this works

1. **Flashing**: Putting the Pico into BOOTSEL mode makes it appear as a USB
   mass-storage drive. Only the host OS can mount that drive, so copying the
   `.uf2` file onto it happens on the host. 
2. **Serial monitor**: reading `printf()` output over USB. On Linux this is
   trivial. On Windows, USB devices aren't visible to Docker Desktop's WSL2
   VM by default — a small tool called `usbipd-win` bridges this gap.

---

## 2. Prerequisites (all platforms)

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (Windows)
  or [Docker Engine](https://docs.docker.com/engine/install/debian/) (Debian)
- [VS Code](https://code.visualstudio.com/)
- The **Dev Containers** VS Code extension (`ms-vscode-remote.remote-containers`)

---

## 3. Linux host setup

### 3.1 Install Docker
Follow Docker's official install guide:
https://docs.docker.com/engine/install/

Then add yourself to the `docker` group so you don't need `sudo` for every
command (log out/in afterward for this to take effect):
```bash
sudo usermod -aG docker $USER
```

### 3.2 Open the project in the container
1. Open this folder in VS Code.
2. VS Code should prompt "Reopen in Container" — click it.
   (Or: Command Palette (Ctrl+Shift+P) → "Dev Containers: Reopen in Container")
3. Wait for the image to build the first time (this downloads/builds the
   Pico SDK and toolchain, so it can take several minutes).

### 3.3 Build
Inside the container's VS Code terminal:
```bash
cmake -G Ninja -B build -DPICO_BOARD=pico2 -DPICO_SDK_PATH=$PICO_SDK_PATH
cmake --build build
```
Or just run the **Build** task: `Ctrl+Shift+B`.

This produces `build/src/pico2_blink.uf2`.

### 3.4 Flash
Put the Pico 2 in BOOTSEL mode: hold the **BOOTSEL** button, plug in the USB
cable, then release BOOTSEL. It will mount as a drive named `RP2350`.

Open a **host** terminal (a normal terminal, NOT the VS Code
container terminal — use VS Code's terminal dropdown to open a "Local" one,
or just use a separate terminal window) and run:
```bash
bash scripts/flash-linux.sh build/src/pico2_blink.uf2
```

### 3.5 Serial monitor
Once flashed, the Pico enumerates as `/dev/ttyACM0` (or similar). Because
this dev container is run with `--privileged -v /dev:/dev` (see
`.devcontainer/devcontainer.json`), `/dev/ttyACM0` is visible *inside* the
container too, so you can use the **Serial Monitor** extension
(already installed) directly in VS Code:
1. Open the "Serial Monitor" panel (bottom panel tabs, or Command Palette →
   "Serial Monitor: Start Monitoring").
2. Select the port (e.g. `/dev/ttyACM0`) and baud rate `115200`.

If you don't see the device in the container, run `ls /dev/ttyACM*` in the
container terminal to confirm it's visible; if not, unplug/replug the Pico
and, if needed, rebuild/reopen the container.

---

## 4. Windows host setup

Windows needs one extra piece of software, **usbipd-win**, because Docker
Desktop's containers run inside a WSL2 Linux VM that can't see Windows USB
devices by default.

### 4.1 Install prerequisites
- Docker Desktop for Windows (with WSL2 backend enabled — this is the default)
- VS Code + Dev Containers extension
- [usbipd-win](https://github.com/dorssel/usbipd-win/releases) — download and
  run the latest `.msi` installer

### 4.2 Open the project in the container
Same as Debian: open the folder in VS Code, click "Reopen in Container", wait
for the build.

### 4.3 Build
Same as Debian (§3.3) — use the integrated terminal inside the container, or
`Ctrl+Shift+B`.

### 4.4 Flash
Put the Pico 2 in BOOTSEL mode (hold BOOTSEL, plug in USB, release). It
mounts as a normal Windows drive (`RP2350`).

Open **PowerShell on Windows** (not inside the container) and run:
```powershell
.\scripts\flash-windows.ps1 build\src\pico2_blink.uf2
```

### 4.5 Serial monitor (requires usbipd-win, one-time-per-device-plug setup)

USB serial passthrough into WSL2/Docker takes a few manual steps **every time
you plug the Pico in** (binding is one-time; attaching is per-session):

1. Open **PowerShell as Administrator** and list devices:
   ```powershell
   usbipd list
   ```
   Find your Pico 2 in the list (it will show as something like
   "USB Serial Device" once it's running your firmware with USB stdio
   enabled — note the BUSID, e.g. `1-4`).

2. **Bind** it (one-time per device, admin required):
   ```powershell
   usbipd bind --busid 1-4
   ```

3. **Attach** it to WSL2 (do this each time you plug the Pico back in;
   does not require admin):
   ```powershell
   usbipd attach --wsl --busid 1-4
   ```
   Make sure a WSL terminal (or Docker Desktop) is running when you do this.

4. Verify it shows up as attached:
   ```powershell
   usbipd list
   ```

5. Back in VS Code (inside the container), the device should now appear as
   `/dev/ttyACM0` (run `ls /dev/ttyACM*` in the container terminal to check).
   Use the Serial Monitor extension as described in §3.5.

**Note:** if `usbipd attach` targets the wrong WSL distribution (Docker
Desktop uses an internal one called `docker-desktop`), you may see an
"Unable to run 'usbip' client tool" error. If that happens, try attaching
while a regular WSL Linux distro terminal is open, or consult the
[usbipd-win WSL support wiki](https://github.com/dorssel/usbipd-win/wiki/WSL-support)
for troubleshooting.

To detach when done: `usbipd detach --busid 1-4`

### **Warning:** 
More needs to be done to get serial working on windows. This is yet to be finalized and automated. 

---

## 5. Project layout

```
.
├── .devcontainer/
│   ├── Dockerfile          # Pico SDK + ARM toolchain + CMake/Ninja image
│   └── devcontainer.json   # VS Code Dev Container config
├── .vscode/
│   └── tasks.json          # Build / Configure / Clean tasks
├── scripts/
│   ├── flash-linux.sh      # Run on a Linux HOST to copy UF2 to the Pico
│   └── flash-windows.ps1   # Run on a Windows HOST to copy UF2 to the Pico
├── src/
│   ├── CMakeLists.txt
│   └── main.c              # Sample blink + USB-serial "hello" program
├── CMakeLists.txt
├── pico_sdk_import.cmake
└── README.md
```

## 6. Customizing for your own project

- Add new source files to `src/` and list them in `src/CMakeLists.txt`
  (`add_executable(...)`, `target_sources(...)`).
- Add extra Pico SDK libraries via `target_link_libraries()`, e.g.
  `hardware_i2c`, `hardware_pwm`, `pico_multicore`, etc. — see the
  [Pico SDK docs](https://www.raspberrypi.com/documentation/microcontrollers/c_sdk.html).
- If you want the LED / UART pin defaults for a *different* board variant
  (e.g. Pico 2 W), change `PICO_BOARD` in both `devcontainer.json` and
  `.vscode/tasks.json` to `pico2_w`, and rebuild the container so the SDK
  configuration step picks up the change.

## 7. Troubleshooting

- **CMake can't find the Pico SDK**: make sure you're running commands
  *inside* the container terminal (where `$PICO_SDK_PATH` is set) not a host
  terminal.
- **Container can't see the Pico's serial port**: unplug/replug the device,
  then check `ls /dev/ttyACM*` in the container terminal. On Windows, confirm
  `usbipd list` shows the device as "Attached" first.
- **Permission denied opening the serial port**: the Dockerfile adds the
  `vscode` user to `dialout`/`plugdev` groups; if this still happens, rebuild
  the container image (Command Palette → "Dev Containers: Rebuild Container").
