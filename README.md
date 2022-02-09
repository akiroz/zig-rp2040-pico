Minimal RP2040 project using zig toolchain with PIO support.

Only requires `zig` installed.

### Usage

```
$ git clone <this repo>
$ zig build -Drelease-fast=true
```

Drag `zig-out/bin/firmware.uf2` into the RP2 bootloader.

### Notes

The main firmware src currently can't be written in ziglang due to heavy use of macro pasting in Pico SDK.
