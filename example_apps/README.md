## Introduction

Some example programs that run on the f64 architecture.

## How to execute

1. Use papilio-prog to load f64.bit to the FPGA.
2. minicom -s (or other suitable serial terminal application)
   * Use 115200 8N1 for the serial port
   * Send the desired .bin file as ASCII (e.g. don't choose xmodem or one of the other protocols)
3. The monitor should come out of sleep mode once the data finishes transferring.

## List of programs

File name | Description
--------- | -----------
print_hello.bin | Prints "hello" on the VGA display.
