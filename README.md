# ⚡ SPI Master-Multi-Slave Controller (SystemVerilog)

A SystemVerilog implementation of a **Serial Peripheral Interface (SPI)** communication system supporting **SPI Mode 0 (`CPOL = 0`, `CPHA = 0`)**. The project demonstrates full-duplex serial communication between a single master and multiple slave peripherals using a shared SPI bus and individual active-low chip-select signals.

The design is simulated using Icarus Verilog and verified through waveform analysis in GTKWave.

## 📌 Project Architecture

```text
SPI/
├── rtl/
│   ├── spi_master.sv
│   ├── spi_slave.sv
│   └── spi_top.sv
├── tb/
│   └── spi_tb.sv
├── spi_waveform.png
└── README.md
```

## ⚙️ Key Features

- **SPI Master Controller:** Generates the serial clock and controls data transmission and reception.
- **Multiple Slave Support:** Supports communication with up to three slave peripherals through individual chip-select signals.
- **SPI Mode 0:** Uses `CPOL = 0` and `CPHA = 0`, with data sampled on rising clock edges.
- **Full-Duplex Communication:** Transmits and receives data simultaneously during each transfer.
- **MSB-First Transmission:** Transfers the most significant bit first.
- **Chip-Select Control:** Uses active-low slave-select signals to select the target peripheral.
- **MISO Bus Sharing:** Models high-impedance behavior for unselected slave outputs where implemented.
- **Self-Checking Testbench:** Verifies communication by comparing received data against expected values.
- **Waveform Verification:** Enables inspection of SPI signals using GTKWave.

## 🧠 Design Overview

### 1. SPI Master (`spi_master.sv`)

The master initiates communication, generates the SPI clock, selects the target slave, and manages serial data transfer.

The controller FSM may include the following operations:

1. **IDLE:** Waits for a transfer request.
2. **START:** Loads the transmit data and selects the target slave.
3. **TRANSFER:** Sends and receives data over eight clock cycles.
4. **STOP:** Completes the transaction, deasserts chip select, and updates the received data and status signals.

### 2. SPI Slave (`spi_slave.sv`)

The slave responds to transactions when its active-low chip-select signal is asserted.

Its responsibilities include:

- Detecting selection through the chip-select signal.
- Loading the data byte to be transmitted.
- Receiving serial data through MOSI.
- Transmitting serial data through MISO.
- Shifting data in the configured bit order.
- Releasing the shared MISO bus when unselected, if supported by the implementation.

### 3. Top Module (`spi_top.sv`)

The top module integrates the master and multiple slave instances.

The SPI bus uses four main signals:

| Signal | Direction | Description |
|---|---|---|
| `SCLK` | Master → Slaves | Serial clock |
| `MOSI` | Master → Slaves | Master Out, Slave In |
| `MISO` | Slaves → Master | Master In, Slave Out |
| `SS` / `CS` | Master → Slaves | Active-low slave selection |

Each slave has its own chip-select signal, allowing the master to select the intended peripheral while sharing the clock and data lines.

### 4. Testbench (`spi_tb.sv`)

The testbench generates clock and reset signals, initiates transactions, and checks whether the master correctly receives data from the selected slave.

## 🔄 SPI Mode 0 Timing

SPI Mode 0 uses the following clock configuration:

- **Clock Polarity (`CPOL = 0`):** SCLK remains LOW when idle.
- **Clock Phase (`CPHA = 0`):** Data is sampled on the leading edge and shifted on the trailing edge.
- **Leading Edge:** Rising edge of SCLK.
- **Trailing Edge:** Falling edge of SCLK.

This arrangement allows data to be sampled on rising edges and updated on falling edges, assuming the RTL follows conventional Mode 0 timing.

## 📊 Simulation and Verification

The design can be simulated using **Icarus Verilog** and analyzed using **GTKWave**.

### Test Scenarios

The following example transactions illustrate communication with three slave peripherals.

| Target Slave | Master Transmits | Slave Transmits | Expected Master Reception |
|---|---|---|---|
| Slave 0 | `0xA5` | `0x5A` | `0x5A` |
| Slave 1 | `0x3C` | `0xC3` | `0xC3` |
| Slave 2 | `0xFF` | `0x00` | `0x00` |

### Expected Testbench Output

```text
================ STARTING SPI BUS TRANSACTIONS ================

[SPI START] Target Slave: 0 | Master Tx: 8'ha5 | Slave Tx: 8'h5a
>>> [RESULT] SUCCESS! Master received Slave's data: 8'h5a <<<

-------------------------------------------------------------------

[SPI START] Target Slave: 1 | Master Tx: 8'h3c | Slave Tx: 8'hc3
>>> [RESULT] SUCCESS! Master received Slave's data: 8'hc3 <<<

-------------------------------------------------------------------

[SPI START] Target Slave: 2 | Master Tx: 8'hff | Slave Tx: 8'h00
>>> [RESULT] SUCCESS! Master received Slave's data: 8'h00 <<<

-------------------------------------------------------------------

================ ALL TESTS COMPLETED ================
```

*Note: This output is illustrative. Actual results depend on the RTL implementation and testbench execution.*

### GTKWave Waveform

Use GTKWave to inspect the SPI clock, MOSI, MISO, chip-select signals, transmitted data, and received data during each transaction.

**Insert your GTKWave screenshot below.**

<img width="811" height="109" alt="Screenshot 2026-10-17 000921" src="https://github.com/user-attachments/assets/4cd7ee56-7ecc-4e9e-9d6d-714df5484a0a" />

## 🛠️ Tools and Technologies

- **SystemVerilog** — RTL design
- **Icarus Verilog** — Compilation and simulation
- **GTKWave** — Waveform visualization
- **Linux / WSL2** — Development environment
- **Git and GitHub** — Version control and project hosting

## 🚀 How to Run the Project

### Prerequisites

Install Icarus Verilog and GTKWave on Ubuntu or WSL2:

```bash
sudo apt update
sudo apt install iverilog gtkwave
```

### 1. Navigate to the Project Directory

```bash
cd ~/Linux/practice/SPI
```

Adjust the path if your project is stored elsewhere.

### 2. Compile the RTL and Testbench

```bash
iverilog -g2012 -o spi_sim.out \
rtl/spi_master.sv \
rtl/spi_slave.sv \
rtl/spi_top.sv \
tb/spi_tb.sv
```

### 3. Run the Simulation

```bash
vvp spi_sim.out
```

### 4. View the Waveform

If the testbench generates `dump.vcd`, open it using:

```bash
gtkwave dump.vcd
```

Ensure the testbench includes the appropriate `$dumpfile` and `$dumpvars` statements to generate the VCD waveform.

## 📚 Concepts Demonstrated

- SPI serial communication
- Master-slave architecture
- Full-duplex data transfer
- SPI clock polarity and phase
- Finite state machines (FSMs)
- Serial-to-parallel and parallel-to-serial conversion
- Shift registers and clock dividers
- Active-low chip-select control
- Shared bus interfacing
- RTL simulation and waveform debugging

## 🔮 Future Improvements

- Support for SPI Modes 1, 2, and 3
- Configurable clock divider and data width
- Configurable bit order (MSB-first or LSB-first)
- More comprehensive randomized testing
- Additional transfer-length and reset-condition tests
- FPGA synthesis and hardware validation

## 📜 License

This project is intended for educational purposes. Add an appropriate open-source license, such as the MIT License, if you intend to distribute it under that license.

---

**Developed as a digital design and verification project using SystemVerilog.**
