
# HWID
### Warning: HWID is a yet to be finished bootable operating system. It can contain various bugs.

**HWID** is a lightweight, bootable hardware identification environment designed to collect detailed information about a computer without requiring the installed operating system.

It runs from a USB drive using a customized SystemRescue environment and presents the collected information through a simple terminal interface.

## Current Version

**V0.1.3**

## Purpose

HWID is designed for rapid hardware identification and inventory.

The goal is to collect as much useful hardware information as possible, including:

- CPU
- GPU
- RAM
- Battery
- Storage
- System firmware
- Serial numbers
- Windows licensing information
- Other low-level hardware information

The collected information can later be transmitted over the network to a central system for inventory processing.

## How To Use
To use HWID, you need to follow these steps:
### Step 1
Download the ISO file from the GitHub Release page and get a USB flash drive, with a minimum of ~4GB recommended.
### Step 2
Use a tool like balenaEtcher or Rufus to flash the ISO onto your USB flash drive.
### Step 3
Eject the USB drive from your computer, and plug it into the computer that needs to be identified.
### Step 4
Boot from the USB by using your motherboard's Boot Menu. Search what you need to do to access it.
### Step 5
Let HWID run and once completed, press ENTER and use `cat /tmp/<SERIALNUMBER>` to view HWID's output. Replace <SERIALNUMBER> with-your device's serial number shown by HWID.

### Currently Implemented

- Bootable SystemRescue-based environment
- Automatic HWID startup
- System serial number detection
- CPU summary collection
- Detailed CPU information
- `/proc/cpuinfo` collection
- GPU hardware detection
- PCI vendor and device identification
- GPU subsystem identification
- PCIe link speed and width detection
- GPU driver detection
- DRM device information
- Detailed PCI GPU information
- Local text report generation
- Terminal-based operation

### Report Location

Reports are currently written to the path:

```text
/tmp/<SERIAL_NUMBER>.txt
