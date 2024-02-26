# Basys3Uart
FPGA Basys3 UART Communication Project with SystemVerilog

Further explained in the project pdf.

This project implements the Universal Asynchronous Receiver-Transmitter (UART) module in SystemVerilog2. UART is a simple hardware for asynchronous serial communication, which can transmit and receive data between two Basys3 boards3. The project consists of four stages:

Stage 1: UART Device4
Design and test a transmitter and a receiver module with 8 data bits, no parity bit, and 2 stop bits.
Use the rightmost eight switches to load data into the transmitter buffer and the rightmost 8 LEDs to display it.
Use the center button to initiate the transmission and the leftmost 8 LEDs to display the received data5.

Stage 2: Register Files for Transmit and Receive Operation6
Allocate two 4-byte memory arrays for storing transmitted and received data, operating as FIFO structures7.
Use the down button to load data from switches into the transmitter array and the center button to send the oldest byte.
Display the most recent data on the rightmost 8 LEDs and the oldest data on the leftmost 8 LEDs5.

Stage 3: Display Contents of Register Files on 7-Segment Display8
Use the 4-digit 7-segment display to show the contents of the transmitter and receiver arrays with groups of 4 hex numbers9.
Use the left and right buttons to shift the display index and the up button to switch between the arrays.
Use LD15 to indicate which array is being displayed and LD11 and LD10 to indicate which page is being displayed10.

Stage 4: Automatic Transfer11
Use the leftmost switch to enable automatic transfer mode, where pressing the center button sends all 4 bytes of the transmitter array to the receiver array.
Preserve the same functionality of the previous stages when the switch is low.
