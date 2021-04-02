//! Rust boilerplate for the Nucleo-WL55JC2 development board.
//!
//! This board uses the [STM32WL55JC] MCU.
//!
//! # Linux Probe Setup
//!
//! These are the [udev rules] I use for the on-board STLINK-V3 probe.
//!
//! Create this file:
//!
//! ```text
//! # /etc/udev/rules.d/99-stm.rules
//! SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374e", MODE="0666"
//! ```
//!
//! Then reload the rules:
//!
//! ```text
//! sudo udevadm control --reload-rules
//! sudo udevadm trigger
//! ```
//!
//! # Running
//!
//! I assume you will use the included probe on the nucleo board (the USB micro
//! port on the back of the PCB, opposite of the antenna).
//!
//! You may have to press the reset button (B4) to see the probe on your system.
//!
//! Use [cargo-embed] to flash the MCU:
//!
//! ```text
//! cargo embed
//! ```
//!
//! That will flash the MCU, and when complete it will bring up an RTT terminal
//! with the logging output from the MCU.
//!
//! # Limitations
//!
//! This is a dual core system, but this boilerplate code completely ignores the
//! M0+ core.
//!
//! [cargo-embed]: https://crates.io/crates/cargo-embed
//! [STM32WL55JC]: https://www.st.com/en/microcontrollers-microprocessors/stm32wl55jc.html#documentation
//! [udev rules]: https://wiki.debian.org/udev

#![no_std]
#![no_main]

use core::fmt::Write;
use core::sync::atomic::{compiler_fence, Ordering::SeqCst};
use rtt_target::rprintln;

#[panic_handler]
fn panic(info: &core::panic::PanicInfo) -> ! {
    cortex_m::interrupt::disable();

    if let Some(mut channel) = unsafe { rtt_target::UpChannel::conjure(0) } {
        channel.set_mode(rtt_target::ChannelMode::BlockIfFull);

        writeln!(channel, "{}", info).ok();
    }

    loop {
        compiler_fence(SeqCst);
    }
}

#[cortex_m_rt::entry]
fn main() -> ! {
    let mut channels = rtt_target::rtt_init! {
        up: {
            0: {
                size: 4096
                mode: BlockIfFull
                name: "Terminal"
            }
        }
    };

    writeln!(&mut channels.up.0, "Hello from writeln!").ok();

    rtt_target::set_print_channel(channels.up.0);
    rprintln!("Hello from rprintln!");

    loop {
        compiler_fence(SeqCst);
    }
}
