# Introduction

F64 is a project to build a 16-bit SoC inside of a FPGA, hopefully improving it in some respects over the retro CPUs from the 80s. The name comes from the largest address in the system, FFFF (aka 64 kilobytes).

This is definitely a work in progress and may be more than someone who's just getting into FPGAs should do.

# Current Status

## What's done

+ VGA display component (80x25 text mode with 8 foreground and background colors @ 640x480)
+ Find a bigger FPGA (now using the Papilio Duo + Computing Shield for development)
+ RS-232 I/O
+ PS/2 I/O
+ Implemented initial version of ISA

## In progress

+ Instruction Set Architecture (ISA) -- see [this](Documentation/ISA.txt) for details.

## To do

+ Interrupt controller
+ Link PS/2 and RS-232 components to core
+ Assembler
+ Performance/timing optimizations

## Possible future enhancements

+ Sound output
+ Joystick input
+ C compiler support
+ Memory segment support (enabling support for more than 64K words/128KB RAM)

# How to contribute

Push requests are always welcome, especially for the ISA document and my (likely) bad Verilog. :D

# License

MIT License.
