# Introduction

F64 is a project to build a 16-bit SoC inside of a FPGA, hopefully improving it in some respects over the retro CPUs from the 80s. The name comes from the hexadecimal F, aka decimal 15 (in other words, 10-1h or 16-1).

This is definitely a work in progress and may be more than someone who's just getting into FPGAs should do.

# Current Status

## What's done

+ VGA display component (80x25 text mode with 8 foreground and background colors @ 640x480)

## In progress

+ Instruction Set Architecture (ISA) -- see [this](Documentation/ISA.txt) for details.

## To do

+ Find a bigger FPGA -- current testing is with an Altera Cyclone II-based FPGA and character ROM + planned 4K video RAM leaves little room for system memory or registers.
+ Implement ISA

# How to contribute

Push requests are always welcome, especially for the ISA document and my (likely) bad Verilog. :D

# License

MIT License.
