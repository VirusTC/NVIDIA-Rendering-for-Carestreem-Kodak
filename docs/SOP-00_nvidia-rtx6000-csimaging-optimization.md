# Hardware Acceleration Optimization Guide: Carestream (CS) Imaging Suite 3.26 & NVIDIA RTX Pro 6000

This document outlines the mandatory configuration protocols required to force the CS Imaging Suite 3.26 platform (2026) to utilize the dedicated hardware pipelines of the NVIDIA RTX Pro 6000 workstation GPU. 

Implementing these changes ensures proper offloading of heavy 2D/3D matrix processing, volumetric rendering, and AI-driven noise-reduction filtering.

---

## 1. Application Executable Inventory
Before beginning configuration, verify the local installation path of your Carestream suite. By default, these files are located in `C:\Program Files (x86)\Carestream\` or `C:\Program Files\Carestream\`. 

You must apply the optimizations in this guide to the following core executables:
*   **`CSImaging.exe`** – The main imaging application interface.
*   **`CSImagingLinkServer.exe`** – The background communication module.
*   **`CSTwain.exe`** / **`DisTwain.exe`** – The hardware acquisition driver interfaces responsible for capturing live raw X-ray data.

---

## 2. Windows OS Graphics Policy Overrides
Windows manages hardware scheduling at the OS level. Follow these steps to force high-performance allocation:

1. Open the Windows **Settings** menu (`Win + I`).
2. Navigate to **System** ➔ **Display** ➔ **Graphics**.
3. Under the **Custom options for apps** section, click **Browse**.
4. Navigate to your Carestream installation folder and select **`CSImaging.exe`**.
5. Once added to the list, click the application name and select **Options**.
6. Set the graphics preference to **High performance** and verify that it explicitly lists the **NVIDIA RTX Pro 6000**. Click **Save**.
7. **Repeat this exact process** for `CSImagingLinkServer.exe`, `CSTwain.exe`, and `DisTwain.exe`.

---

## 3. NVIDIA Control Panel Hardware Mapping
To override global driver defaults and map specific GPU compute units to the software:

1. Right-click an empty space on the desktop and select **NVIDIA Control Panel**.
2. Expand the **3D Settings** node in the left sidebar and select **Manage 3D Settings**.
3. Navigate to the **Program Settings** tab in the main pane.
4. Click the **Add** button. If `CSImaging.exe` is not in the recent programs list, click **Browse** to select it from its installation directory.
5. Change the **Preferred graphics processor** drop-down menu to **High-performance NVIDIA processor**.
6. In the feature settings list below, locate **CUDA - GPUs**. Click the drop-down menu, uncheck "Use global setting", ensure your **NVIDIA RTX Pro 6000** is checked, and click **OK**.
7. Locate **OpenGL rendering GPU** in the settings list and explicitly change it from "Autoselect" to **NVIDIA RTX Pro 6000**.
8. Click **Apply** in the bottom right corner to save changes.

---

## 4. Windows Graphics Performance Enhancements
To maximize data transfer speeds between the X-ray sensor interface and the GPU:

### Enable Hardware-Accelerated GPU Scheduling (HAGS)
1. Go back to Windows **Settings** ➔ **System** ➔ **Display** ➔ **Graphics**.
2. Click on **Change default graphics settings** (at the top of the menu).
3. Toggle **Hardware-accelerated GPU scheduling** to **On**.
4. Restart the workstation to apply changes.

### Configure Workstation Power Plan
1. Open the Windows Control Panel and navigate to **Power Options**.
2. Select the **Ultimate Performance** or **High Performance** power plan. This prevents the PCIe slots from entering low-power states, reducing data latency during raw X-ray capture.

---

## 5. Verification Protocol
To confirm the configuration is active during clinical operations:

1. Launch **Windows Task Manager** (`Ctrl + Shift + Esc`).
2. Click the **Performance** tab and select your **NVIDIA RTX Pro 6000** GPU from the left list.
3. Open **CS Imaging Suite 3.26** and initialize an acquisition sequence or pull up a heavy 3D volumetric file.
4. Observe the **3D** and **Compute_0** (or **CUDA**) graphs in Task Manager. A distinct utilization spike should occur when the software renders or filters the exposure data, confirming successful GPU handoff.
