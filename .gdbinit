target extended-remote localhost:3333
set print asm-demangle on
monitor reset init
monitor reset halt
load
