# FIFO
The "FIFO Basic Operation" test case is designed to verify the fundamental functionality of a FIFO (First-In-First-Out) memory. The test steps cover initialization, data writing, verification of data writing order, data reading, verification of data reading order, and testing boundary conditions such as overflow and underflow scenarios.

# DEFINITION
A FIFO (First-In-First-Out) is a data structure used in digital circuits and systems to store and retrieve data in a specific order: the first data item to enter the FIFO is the first one to exit. It's like a queue in a real-world scenario where people wait in a line, and the person who arrives first is served first. In a digital context, a FIFO is particularly useful for buffering data between two parts of a system with different data rates or processing speeds.

Let's break down the theory behind a FIFO with a diagram and waveform:

**1. FIFO Diagram:**

![image](https://github.com/swapnilanand123/FIFO/assets/143795450/f805b0b3-ac18-441b-aec0-a3deb8fdba82)


A typical FIFO consists of the following components:

- **Data Input (Write Port):** This is where you write (or push) data into the FIFO. It includes a data input signal (`DIN`), a write enable signal (`WE`), and a write pointer (`WR_PTR`) that keeps track of the position where data is being written.

- **Data Output (Read Port):** This is where you read (or pop) data from the FIFO. It includes a data output signal (`DOUT`), a read enable signal (`RE`), and a read pointer (`RD_PTR`) that keeps track of the position where data is being read.

- **FIFO Memory:** This is the actual memory block where data is stored. It can be implemented using registers or flip-flops.

- **Control Logic:** This logic controls the read and write operations, manages pointers, and monitors the FIFO's status (empty or full).

- **Status Flags:** Typically, there are status flags indicating whether the FIFO is empty (`EMPTY`) or full (`FULL`), which can be used to control the read and write operations.

**2. FIFO Waveform:**

Here's a simplified waveform diagram of a FIFO operation:
![image](https://github.com/swapnilanand123/FIFO/assets/143795450/34fc9277-3beb-473f-b867-3cd8ab2dd5f0)

- Initially, the FIFO is empty (`EMPTY` = 1) with both write and read pointers at the same position.

- Data1, Data2, Data3, Data4, and Data5 are written into the FIFO with `WE` = 1.

- The read operation (`RD`) is enabled after some data is written. The data is read in the same order it was written (`Data1` first, then `Data2`, and so on).

- As data is read, the read pointer advances and the FIFO status changes from empty to having data.

- If more data is written than read, the FIFO can become full (`FULL` = 1), and further write operations might be blocked until some data is read out.

In real-world applications, FIFOs can have different sizes, more complex control logic, and additional features like programmable flags, almost-empty and almost-full thresholds, and more, depending on the specific requirements of the design.


RTL to GDSII flow: -

![Screenshot from 2023-10-02 10-53-50](https://github.com/swapnilanand123/FIFO/assets/143795450/79c2483d-5dac-4e8f-96aa-c76e2229a4a6)

![Screenshot from 2023-10-02 10-54-00](https://github.com/swapnilanand123/FIFO/assets/143795450/62a13c37-a7e8-4834-99d8-28297ece134c)

```
~/OPENROAD_FLOW/OpenROAD-flow-scripts/flow/designs/sky130hd/fifo$ gedit config.mk 
```
![Screenshot from 2023-10-02 10-43-38](https://github.com/swapnilanand123/FIFO/assets/143795450/574f70fc-9bbe-4f28-b78d-d511e0d9d2e9)

```
~/OPENROAD_FLOW/OpenROAD-flow-scripts/flow/designs/sky130hd/fifo$ gedit constraint.sdc
```
![Screenshot from 2023-10-02 10-43-04](https://github.com/swapnilanand123/FIFO/assets/143795450/48d5c8bb-2684-4de8-b2bb-1aa236ada565)

```
OPENROAD_FLOW$ source ORFS_bashrc
OPENROAD_FLOW/OpenROAD-flow-scripts/flow$ make DESIGN_CONFIG=./designs/sky130hd/fifo/config.mk
```
![Screenshot from 2023-10-02 10-54-34](https://github.com/swapnilanand123/FIFO/assets/143795450/247c8f41-6d98-4ffc-9262-0ad7d9283318)
![Screenshot from 2023-10-02 10-55-27](https://github.com/swapnilanand123/FIFO/assets/143795450/20d32183-c0f6-479f-ae40-b466dbffbddc)


```
OPENROAD_FLOW/OpenROAD-flow-scripts/flow$ make DESIGN_CONFIG=./designs/sky130hd/fifo/config.mk gui_final
```
![Screenshot from 2023-10-02 10-56-57](https://github.com/swapnilanand123/FIFO/assets/143795450/949d5b84-fa63-4b38-95c7-3d2763fe0e64)


```
OPENROAD_FLOW/OpenROAD-flow-scripts/flow$ klayout -s ./results/sky130hd/fifo/base/6_final.gds -l ./platforms/sky130hd/sky130hd.lyp
```
![Screenshot from 2023-10-02 11-00-14](https://github.com/swapnilanand123/FIFO/assets/143795450/051bbe31-52c9-4876-a998-e879b9156dd3)



