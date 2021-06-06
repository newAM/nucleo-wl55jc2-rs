![Maintenance](https://img.shields.io/badge/maintenance-experimental-blue.svg)
[![CI](https://github.com/newAM/nucleo-wl55jc2-rs/workflows/CI/badge.svg)](https://github.com/newAM/nucleo-wl55jc2-rs/actions)

# nucleo-wl55jc2

Rust boilerplate for the Nucleo-WL55JC2 development board.

There is a work-in-progress HAL for this MCU here: [stm32wl-hal]

This board uses the [STM32WL55JC] MCU.

## Linux Probe Setup

These are the [udev rules] I use for the on-board STLINK-V3 probe.

Create this file:

```
# /etc/udev/rules.d/99-stm.rules
SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374e", MODE="0666"
```

Then reload the rules:

```
sudo udevadm control --reload-rules
sudo udevadm trigger
```

## Running

I assume you will use the included probe on the nucleo board (the USB micro
port on the back of the PCB, opposite of the antenna).

You may have to press the reset button (B4) to see the probe on your system.

Use [cargo-embed] to flash the MCU:

```
cargo embed
```

That will flash the MCU, and when complete it will bring up an RTT terminal
with the logging output from the MCU.

## Limitations

This is a dual core system, but this boilerplate code completely ignores the
M0+ core.

[stm32wl-hal]: https://github.com/newAM/stm32wl-hal
[cargo-embed]: https://crates.io/crates/cargo-embed
[STM32WL55JC]: https://www.st.com/en/microcontrollers-microprocessors/stm32wl55jc.html#documentation
[udev rules]: https://wiki.debian.org/udev
