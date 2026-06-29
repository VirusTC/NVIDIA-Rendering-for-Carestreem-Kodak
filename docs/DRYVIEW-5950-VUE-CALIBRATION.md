# DryView 5950 & Carestream Vue DICOM Calibration

This document details the configuration for the Carestream DryView 5950 Laser Imager.
It ensures parity between NVIDIA-accelerated monitors and physical transparencies.

## 🔀 DICOM Media Profile & Tray Routing
Carestream Vue PACS must separate standard film from premium clear base sheet upgrades.

* **Tray 1 (Standard)**: Maps to Blue Base DryView Laser Imaging Film (DVB).
* **Tray 2 (Premium)**: Maps to Clear Base Film for light-board use.
* **Routing Filter**: Triggered via the `Premium_Clear_Sheet` billing modifier macro.
* **SOP Class UID**: Enforced via Basic Grayscale Print Management (`1.2.840.10008.5.1.1.18`).

## 🎚️ FDA-Mandated Adobe Look-Up Table (LUT) Calibration
To preserve Adobe-layered vector transparency profiles, use an Adobe Gamma curve profile.

* **Grayscale Calibration**: Align imager internal LUT directly with DICOM GSDF limits.
* **Clear Base Contrast**: Enforce strict minimum density (`Dmin = 0.20`) presets.
* **Blue Base Contrast**: Enforce strict maximum density (`Dmax = 3.20`) boundaries.
* **Interpolation Mode**: Set the DryView web portal profile to Linear Interpolation.

## 🚦 Verification Checklist
1. Validate that the Carestream Vue client transmits 12-bit grayscale data.
2. Confirm the internal heat processor operates at 125°C.
3. Verify film development dwell time is exactly 23 seconds.
