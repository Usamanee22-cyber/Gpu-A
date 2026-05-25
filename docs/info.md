## How it works

This project implements a highly optimized **16-Bit Hybrid AI Matrix Processing Engine combined with a GPU VGA Raster Signal Pipeline**. 

The hardware architecture consists of two main processing units:
1. **GPU VGA CRT Display Pipeline:** Automatically generates industry-standard VGA timing signals (`h_sync` and `v_sync`) targeting a 640x480 screen resolution at a 60Hz refresh rate. It scans through a local frame layout coordinates, dynamically calculating a pixel layout color spectrum by XOR-ing the internal accumulator state with the current raster X-coordinate position.
2. **AI Co-Processor Core:** Features an internal 16-word SRAM instruction cache that feeds an execution state-machine. It supports custom Vector Multiply-Accumulate (MAC) matrix operations, processing four 16-bit register vector arrays (`reg_vector_x` and `reg_vector_y`) simultaneously. It also integrates a hardware-level ReLU (Rectified Linear Unit) activation function activation filter for tiny machine learning inferences.

Data output is split: video synchronization and partial pixel color data are routed through the primary output pins (`uo_out`), while the low 8-bits of the raw AI matrix arithmetic computation results are exposed via the bidirectional I/O pins (`uio_out`).

## How to test

To test and simulate the behavior of this custom AI+GPU processor, follow these steps:

1. **System Initialization:** Apply a master clock signal to the `clk` input (driven up to 10 MHz). Toggle the global asynchronous reset line `ui_in[1]` (Active-Low) to low, and pull it back to high to safely initialize the VGA raster scan states, registers, and internal instruction arrays.
2. **GPU Video Verification:** Monitor the primary outputs `uo_out[0]` (H-SYNC) and `uo_out[1]` (V-SYNC) using a digital logic analyzer or oscilloscope. Verify that the pulses match standard 640x480 timing frequencies. Check `uo_out[2]` (Display Valid) to ensure it toggles high only during active display areas.
3. **AI Core Arithmetic Test:** Observe the bidirectional data output lines `uio_out[7:0]`. As the internal state machine cycles through the hardcoded SRAM pipeline instructions (loading vectors, multiplying arrays, and executing ReLU checks), `uo_out[2]` will flash high, indicating that the final matrix computation result has been successfully dumped to the register bus.

## External hardware

This project is completely self-contained within the digital logic cells, but to witness its full visual potential externally, the following hardware peripherals can be attached:
* **Tiny Tapeout VGA PMOD Module:** Connects directly to the `uo_out` port to convert the digital H-SYNC, V-SYNC, and 5-bit pixel bits into analog signals for an external VGA monitor display screen.
* **Digital Logic Analyzer / Oscilloscope:** Hooked up to `uio_out[7:0]` to read out the live binary numbers being processed by the underlying matrix neural network layer.
