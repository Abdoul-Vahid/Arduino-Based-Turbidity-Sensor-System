# FINAL PROJECT SSF – DUCKSAVER3000
## Automated Water Quality & Turbidity Monitoring System

**Group Members:** 

Abdoul-Vahid Akhmadov 2506698011

Théodène FOULON	2506698005

Nadira Fayyaza Aisy 2406368933

Syifa Sarah Nuraini 2406368883


---

### Introduction
The **Automated Water Quality Monitoring System** is an optimized, bare-metal embedded system driven by the ATmega328P microcontroller to track water clarity levels in real time using an analog turbidity sensor. Developed fully in low-level AVR Assembly language, the firmware manages precise hardware timing, automated 10-bit analog-to-digital conversions, inline multi-byte arithmetic calculations to map NTU values, and a multi-tier visual and serial telemetry signaling framework. 

In this architectural layout, the system switches from serial I2C communication to an optimized **4-bit parallel bus interface** to handle data transfer to a standard 16x2 Liquid Crystal Display (LCD), demonstrating advanced micro-architectural pin reuse and resource management.

---

### Main Features
* **Interrupt-Driven Scheduling:** Operates via Timer1 in CTC mode, utilizing the Compare Match A hardware interrupt vector (`__vector_11`) to execute automated evaluation routines without pipeline blocking.
* **Inline NTU Scaling and Computation:** Employs dynamic 16-bit subtraction and fixed-point scale multiplications directly within the ISR to compute specific Nephelometric Turbidity Units (NTU), including full numerical overflow handling ($> 999$ NTU).
* **Three-Tier Water Quality Classification:** Categorizes aquatic safety into three specific zones using conditional branching:
  * **CLEAN:** Low turbidity conditions.
  * **NORMAL:** Medium turbidity conditions.
  * **DIRTY:** High turbidity / contaminated conditions.
* **Direct 4-Bit Parallel LCD Driver:** Controls a 16x2 character LCD using a high-speed parallel nibble transmission method (`send_nibble`) across split I/O ports.
* **Tri-LED Visual Alarm Matrix:** Dedicated digital output pins drive distinct colored status indicators corresponding directly to each individual water safety tier.
* **Live Text Telemetry Stream:** Outputs real-time ASCII data values (`NTU: XYZ`) over USART serial interface at a stabilized 9600 baud rate.

---

### Module Structure
The low-level source architecture is organized into clearly defined functional blocks:
* **Vector Table Alignment:** Configures the hardware execution branch to route the Timer1 Compare Match routine directly to the primary processing logic at `__vector_11`.
* **Hardware Setup (`setup`):** Manages data direction configurations (DDR registers), clears internal status registers, programs the 128-prescaler ADC module, sets up USART baud matrices, and launches the parallel LCD initialization routine.
* **Mathematical Processor Core:** Handles raw 10-bit binary conversions from the sensor, applies linear correction logic, and runs an iterative 16-bit subtraction division loop (`div_loop`) to determine final NTU values.
* **Parallel LCD Controller:** Employs nibble splitting (`swap`), command routing (`lcd_cmd`), and character generation loops (`lcd_data`, `lcd_print`) to drive data directly onto the parallel system bus.
* **Asynchronous UART Driver:** Polls the USART Data Register Empty flag (`UDRE0`) to process and stream continuous string literals and multi-digit values smoothly.

---

### Required Components

| Component Name | Quantity | Description |
| :--- | :--- | :--- |
| **ATmega328P MCU** (Arduino Uno) | 1 | Core micro-processing and data control unit |
| **Analog Turbidity Sensor + Probe** | 1 | Optical sensing module measuring light dispersion in liquid |
| **16x2 Character LCD** | 1 | Parallel display module interface |
| **Clean Status LED** | 1 | Visual indicator for pristine water conditions |
| **Normal Status LED** | 1 | Visual indicator for acceptable water conditions |
| **Dirty Status LED** | 1 | Visual indicator for critical contamination levels |
| **9V Battery / DC Power Rail** | 1 | Main stable power source for standalone operations |
| **Prototyping Breadboard & Wire Set** | 1 | Physical interface links |

---

### ATmega328P Pin Configuration

| Function / Peripheral | ATmega328P Pin | Physical / Arduino Mapping |
| :--- | :--- | :--- |
| **Turbidity Sensor Input** | PC0 | Analog Input Pin **A0** |
| **LCD Register Select (RS)** | PB0 | Digital Pin **8** |
| **LCD Enable (EN)** | PB1 | Digital Pin **9** |
| **LCD Parallel Data Bus (D4–D7)** | PD4 – PD7 | Digital Pins **4, 5, 6, 7** |
| **Clean LED Indicator** | PD4 | Digital Pin **4** (Shared Bus pin) |
| **Normal LED Indicator** | PD5 | Digital Pin **5** (Shared Bus pin) |
| **Dirty LED Indicator** | PB5 | Digital Pin **13** (Onboard LED) |
| **UART TX (Serial Output)** | PD1 | Digital Pin **1** / TX |
| **UART RX (Serial Input)** | PD0 | Digital Pin **0** / RX |

---

### System Workflow
1. **Peripheral Power-On Setup:** The controller sets output directions for parallel data manipulation, configures the serial transmission registers for 9600 baud, sets up the ADC reference, launches an extended multi-stage delay to safely initialize the parallel LCD display matrix, and activates global interrupts (`sei`).
2. **Periodic Interrupt Fire:** Timer1 matches its compare registers, pausing the background listening frame to enter the `__vector_11` routine.
3. **ADC Conversion Loop:** The system forces the `ADSC` bit high, samples the current analog voltage line coming from the probe on Pin **A0**, and locks the conversion results inside `ADCL` and `ADCH`.
4. **NTU Translation & Math Block:** The firmware processes raw hardware voltage through a mathematical translation sequence to subtract baseline properties, scales the results through automated bit shifts (`lsl`/`rol`), and executes an assembly division sequence to calculate the final scalar value.
5. **Threshold Verification & Branching:**
   * **Clean State:** If calculated parameters stay within safe bounds, the system turns on the Clean LED, clears alternative lights, and sends a `Status: CLEAN` data packet to the LCD.
   * **Normal State:** If turbidity values slide into mid-range limits, the Normal LED is latched high, and a `Status: NORMAL` data packet is written to the screen.
   * **Dirty State:** If values cross critical pollution marks, the Dirty LED flashes on, and a `Status: DIRTY` warning is pushed onto the LCD grid.
6. **Telemetry Transmission:** The live calculated numerical value is converted into ASCII characters on-the-fly and streamed out through the UART port (`NTU: XYZ` or `> 999` if overloaded) before restoring context registers and returning to normal execution.
