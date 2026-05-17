# FINAL PROJECT SSF – DUCKSAVER3000
## Automated Water Quality & Turbidity Monitoring System

**Group Members:** 

Abdoul-Vahid Akhmadov 2506698011
Théodène FOULON	2506698005
Nadira Fayyaza Aisy 2406368933
Syifa Sarah Nuraini 2406368883


---


### Introduction
The **Automated Water Quality Monitoring System** is an ATmega328P microcontroller-based device designed to evaluate water clarity in real time using an analog turbidity sensor. Built entirely in low-level AVR Assembly language, the system leverages hardware timers, analog-to-digital conversion, 16-bit logic arithmetic, I2C/TWI communication protocols, and UART serial logging to determine whether a water sample is clean or dirty. 

This system provides an optimized, bare-metal approach to environmental sensing, suitable for industrial automation, smart agriculture, and fluid monitoring applications.

---

### Main Features
* **Automated Periodic Sampling:** Utilizes hardware Timer1 in CTC mode to trigger precise water quality checks every 1 second via interrupts.
* **Hardware ADC Processing:** Samples analog voltage variations from the turbidity sensor to measure water clarity levels accurately.
* **16-bit Arithmetic Evaluation:** Compares the high and low bytes of the 10-bit ADC output against a predefined safety threshold (value < 201) to instantly categorize water quality.
* **Dual-Mode Visual Indicators:** Controls an onboard status LED and outputs dedicated signals to a 16x2 LCD screen over an I2C communication bus.
* **Telemetry Data Logging:** Streams continuous status bytes (`C` for Clean, `D` for Dirty) to an external monitoring console via UART at 9600 baud.

---

### Module Structure
The assembly codebase is architected into specific procedural sections handling core hardware sub-systems:
* **Interrupt Vector Table:** Maps the system reset routine and handles the `timer1_isr` peripheral execution loop.
* **Hardware Initialization:** Configures the Stack Pointer, I/O directions, USART communication registers, Analog Multiplexer (ADMUX), TWI bit rates, and Timer1 counters.
* **Logic & Processing Core (`timer1_isr`):** Triggers the ADC conversion loop, reads 16-bit register outputs, executes threshold comparisons, and branches to conditional signaling routines.
* **Serial Subroutines (`ser_send`):** Checks USART Data Register Empty flags (`UDRE0`) and handles byte transmission over serial.
* **I2C / TWI Driver Core:** Formulates the communication pipeline (`i2c_start`, `i2c_write`, `i2c_stop`) used to transmit data frames to the LCD liquid crystal display backpack interface.

---

### Required Components

| Component Name | Quantity | Description |
| :--- | :--- | :--- |
| **ATmega328P MCU** (Arduino Uno) | 1 | Main system processing and controller unit |
| **Analog Turbidity Sensor + Probe** | 1 | Optical sensor measuring light transmission through water |
| **16x2 LCD with I2C Backpack** | 1 | Character display unit utilizing PCF8574 I2C adapter (Address `0x27`) |
| **Status LED** (Onboard or External) | 1 | Visual indicator for alert and clean status signaling |
| **9V Battery / DC Power Supply** | 1 | Main power supply rail for the standalone system |
| **Breadboard & Jumper Wires** | 1 set | Physical prototyping connections |

---

### ATmega328P Pin Configuration

| Function | ATmega328P Pin | Physical / Arduino Mapping |
| :--- | :--- | :--- |
| **Turbidity Sensor Analog Out** | PC0 | Analog Input Pin **A0** |
| **Status LED Indicator** | PB5 | Digital Pin **13** (Onboard LED) |
| **I2C SDA (Data Line)** | PC4 | Analog Pin **A4** / Dedicated SDA |
| **I2C SCL (Clock Line)** | PC5 | Analog Pin **A5** / Dedicated SCL |
| **UART TX (Serial Transmit)** | PD1 | Digital Pin **1** / TX |
| **UART RX (Serial Receive)** | PD0 | Digital Pin **0** / RX |

---

### System Workflow
1. **System Wake & Init:** The microcontroller configures memory bounds, sets up peripheral registers (9600 Baud UART, 100kHz I2C, 1-second Timer1 interrupts), initializes the I2C LCD screen, and enters an optimized `idle` loop.
2. **Interrupt Triggering:** Every 1 second, Timer1 reaches its target match register, pausing the idle loop to jump into the `timer1_isr` block.
3. **Sensor Processing:** The ADC samples the analog voltage coming from the turbidity sensor on pin **A0**. The 10-bit result is processed through registers `ADCL` and `ADCH`.
4. **16-bit Threshold Comparison:** The 10-bit sensor value is evaluated against the clear-water baseline threshold of **201**.
5. **Conditional Feedback Execution:**
   * **If Water is Clean (>= 201):** Pin `PB5` is pulled `LOW` (LED turns off), and the ASCII character `'C'` is sent across the UART interface to log a safe status.
   * **If Water is Dirty (< 201):** Pin `PB5` is driven `HIGH` (LED turns on to alert the user), and the ASCII character `'D'` is sent across the UART line to signal contamination.
6. **Display Refresh:** The program initiates the I2C routine to transmit state metrics directly to the 16x2 display module before resetting the interrupt flags and returning to the idle loop.
