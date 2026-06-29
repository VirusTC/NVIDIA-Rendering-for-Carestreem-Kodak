# Windows Registry Optimization for NVIDIA Pipelines

This document lists FDA-compliant registry overrides for diagnostic workstation stability.
These prevent rendering mismatches between local software and printed film outputs.

## 🗲 NVIDIA Hardware Acceleration Overrides
Inject these values to stabilize local hardware context initialization hooks.

* **Path**: `HKLM:\SOFTWARE\NVIDIA Corporation\Global\Stereo3D`
* **Key**: `EnableMedicalImagingOptimizations` (DWORD = `1`)
* **Purpose**: Locks high-performance CUDA context paths for local client pipelines.

## 🛡️ TDR Windows Stability Controls
Prevent Windows from resetting the GPU driver during intense AI denoising loops.

* **Path**: `HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers`
* **Key**: `TdrDelay` (DWORD = `10`)
* **Purpose**: Extends Timeout Detection and Recovery time limit to 10 seconds.

## 💻 Carestream Vue Client Hooks
Force the Vue application layer to prioritize dedicated hardware rendering assets.

* **Path**: `HKLM:\SOFTWARE\Carestream\VuePACS\Client\Rendering`
* **Key**: `ForceNvidiaHardwareDecode` (DWORD = `1`)
* **Purpose**: Restricts color space mapping anomalies by isolating NVDEC pipelines.
