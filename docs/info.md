## How it works
This project implements a 16-Bit AI Matrix Processing Engine with a GPU VGA Raster Signal Pipeline.
1. **GPU VGA Display Pipeline:** Generates VGA timing signals (`h_sync`, `v_sync`) for 640x480 @ 60Hz. It dynamically calculates pixel colors by XOR-ing the accumulator state with the scan position.
2. **AI Co-Processor Core:** Features a 16-word SRAM instruction cache, an execution state-machine supporting Vector MAC operations, and a hardware-level ReLU activation layer.

## How to test
1. **Initialization:** Drive `clk` (up to 10 MHz). Toggle reset `ui_in[1]` (Active-Low) to initialize states.
2. **GPU Video Verification:** Monitor `uo_out[0]` (H-SYNC) and `uo_out[1]` (V-SYNC) for standard 640x480 frequencies. Check `uo_out[2]` (Display Valid) for active display areas.
3. **AI Computation Test:** Observe `uio_out[7:0]` to read the lower 8-bits of the final matrix calculation results when `uo_out[2]` flashes.

## External hardware
* **Tiny Tapeout VGA PMOD Module:** Connects to `uo_out` to interface with an external VGA display screen.
* **Logic Analyzer / Oscilloscope:** Connects to `uio_out[7:0]` to capture live matrix calculation outputs.
