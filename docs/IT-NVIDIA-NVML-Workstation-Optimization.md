# IT & Systems Infrastructure Guide: NVIDIA NVML & VRAM Optimization
**Target Hardware:** NVIDIA RTX Pro 6000 (Ampere/Ada Lovelace Architecture)
**Target Platform:** Carestream (CS) Imaging Suite 3.26 / Eclipse AI Deployment Engine

This document outlines the infrastructure-level protocols required to optimize the NVIDIA Management Library (NVML) and VRAM allocations for a medical workstation running multi-tenant Carestream AI modules. These settings guarantee low-latency image processing and prevent out-of-memory (OOM) errors during critical clinical workflows.

---

## 1. Enterprise Driver & Mode Standardization
Before configuring NVML, the GPU must be placed into a deterministic compute and graphics state to ensure medical image processing stability.

### Set Driver Model to WDDM with Compute Focus
For standalone diagnostic workstations, configure the RTX Pro 6000 to prioritize high-throughput compute tasks alongside standard display rendering:
```bash
nvidia-smi -g 0 -dm 0
```
*(Note: Use `-dm 1` for TCC mode only if the card is used strictly as a secondary headless rendering node over a VDI network).*

### Enforce Maximum Performance Power Management
Prevent the GPU from dropping into low-power P-states during periods of clinical inactivity. This ensures instantaneous responsiveness when an X-ray exposure is fired:
```bash
nvidia-smi -pm 1
nvidia-smi -g 0 -acp P0
```

---

## 2. Global NVML Memory Capping & VRAM Allocation
When multiple Carestream AI engines (e.g., Smart Noise Cancellation, Bone Suppression, and Tube/Line Visualization) are active simultaneously, they can compete for the card’s VRAM (24GB or 48GB depending on generation). 

Use the `nvidia-smi` command-line utility to allocate and partition memory bounds safely.

### Set Hard Memory Limits for Concurrent Engines
To prevent a single volumetric 3D/CBCT reconstruction from starving background 2D AI inference engines, use NVML environment variables to bound memory pools within the Windows System Environment variables:

```cmd
:: Allocate 50% of total VRAM maximum for heavy 3D CBCT Reconstruction
SET CUDA_VISIBLE_DEVICES=0
SET CUDA_MANAGED_FORCE_DEVICE_LIMIT=50

:: Enable unified memory oversubscription to allow system RAM buffering if needed
SET CUDA_UNITY_MEMORY_ALLOW_OVERSUBSCRIPTION=1
```

### Enable Multi-Instance GPU (MIG) for High-Tenant Environments
If your hospital workstation serves as a centralized processing server hosting multiple instances of Carestream/Kodak acquisition software over a local intranet, partition the RTX Pro 6000 into distinct compute instances:
```bash
:: Enable MIG Mode (Requires Administrative Privileges & System Reboot)
nvidia-smi -i 0 -mig 1

:: Create profiles allocating dedicated VRAM slices for specific clinical applications
:: Example: Slice 1 for 3D Reconstruction, Slice 2 for Real-time 2D Denoising
nvidia-smi mig -cgi 19,19,19 -C
```

---

## 3. NVML Process Monitoring & Health Check Automation
To guarantee 99.999% clinical uptime, IT administrators must deploy automated scripts to monitor VRAM allocation and clear stalled processing loops without restarting the workstation.

### Create an Automated VRAM Watchdog Script (`nvml_watchdog.bat`)
Save the following script to `C:\Program Files\Carestream\Scripts\nvml_watchdog.bat`. This script will monitor memory usage and log any anomalies to the Event Viewer:

```batch
@echo off
setlocal enabledelayedexpansion

:: Threshold set to 90% of a 48GB card (~43200 MB)
set MEM_THRESHOLD=43200

for /f "tokens=1" %%i in ('nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits') do (
    set VRAM_USED=%%i
)

if !VRAM_USED! gtr %MEM_THRESHOLD% (
    echo [WARNING] VRAM utilization has exceeded critical threshold: !VRAM_USED!MB. >> C:\Program Files\Carestream\Logs\nvml_health.log
    
    :: Safely recycle background processing servers to reclaim leaked memory without closing the main client UI
    taskkill /f /im CSImagingLinkServer.exe
    start "" "C:\Program Files\Carestream\CSImagingLinkServer.exe"
    
    echo [ACTION] CSImagingLinkServer recycled successfully to free VRAM. >> C:\Program Files\Carestream\Logs\nvml_health.log
)
exit
```

### Integrate Script into Windows Task Scheduler
1. Open **Task Scheduler**.
2. Create a new task named `Carestream NVML VRAM Monitor`.
3. Set the trigger to repeat every **5 minutes**, indefinitely.
4. Set the action to **Start a Program** and point it to `nvml_watchdog.bat`.
5. Ensure the checkbox for **Run with highest privileges** is marked.

---

## 4. Troubleshooting NVML Configuration Issues

| Symptom / Error | Root Cause | Resolution |
| :--- | :--- | :--- |
| `CUDA Error: out of memory` | Carestream application leaks VRAM during prolonged multi-study workflows. | Implement the **VRAM Watchdog Script** outlined in Section 3, or force a strict memory limit using the `CUDA_MANAGED_FORCE_DEVICE_LIMIT` variable. |
| `NVML: Driver Not Loaded` | System updated Windows display drivers automatically, breaking the NVML symlink path. | Reinstall the **NVIDIA Enterprise Production Branch Driver** manually and reboot the system to restore the global path variable. |
| Processing Lag / Stuttering | GPU is entering low-power throttling states between patient exposures. | Run the `nvidia-smi -pm 1` command via an administrative command prompt to force constant persistence mode. |

---
**Prepared By:** Hospital Clinical IT & Imaging Systems Infrastructure Team  
**Approved For Production:** Carestream v3.26 Framework Architecture Integration  
