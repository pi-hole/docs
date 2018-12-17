# *FTL*DNS compatibility list

We tested *FTL*DNS on the following devices:

| Board | Tested OS | CPU architecture | Suitable binaries
|---|---|---|---
| VirtualBox | Ubuntu 16.10 | amd64 | `linux-x86_64`
| Raspberry Pi Zero | Raspbian Jessie, Stretch | armv6l | `arm-linux-gnueabi`
| Raspberry Pi 1 | Raspbian Jessie, Stretch | armv6 | `arm-linux-gnueabi`
| Raspberry Pi 2 | Raspbian Jessie, Stretch | armv7l | `arm-linux-gnueabi` and `arm-linux-gnueabihf`
| Raspberry Pi 3 | Raspbian Jessie, Stretch | armv7l | `arm-linux-gnueabi` and `arm-linux-gnueabihf`
| Raspberry Pi 3 B+ | Raspbian Jessie, Stretch | armv7l | `arm-linux-gnueabi` and `arm-linux-gnueabihf`
| Raspberry Pi 3 | openSUSE | aarch64 | `aarch64-linux-gnu`
| NanoPi NEO | armbian Ubuntu 16.04 | armv7l | `arm-linux-gnueabihf`
| Odroid-C2 | Ubuntu 16.04 | aarch64 | `aarch64-linux-gnu`
| C.H.I.P | Debian | armv7l | `arm-linux-gnueabihf`
| OrangePi Zero | armbian Ubuntu 16.04 | armv7l | `arm-linux-gnueabihf`
| BeagleBone Black| Debian Jessie, Stretch | armv7l | `arm-linux-gnueabihf`

<!-- |  |  |  |  |  | -->

Devices we do not officially support include MIPS and `armv5` (or lower) devices. You may, however, be successful with building binaries yourself from the source code, but we do not provide pre-built binaries for these targets.

{!abbreviations.md!}
