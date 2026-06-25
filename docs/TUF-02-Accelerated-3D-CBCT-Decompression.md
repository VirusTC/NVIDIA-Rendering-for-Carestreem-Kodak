# Endpoint Optimization: 3D/CBCT Volumetric Viewport Decompression
**Target Hardware:** ASUS TUF GeForce RTX 50 Series (Client Endpoint Node)  
**Upstream Source:** NVIDIA RTX Pro 6000 (Datacenter / Acquisition Node via Multi-Pass Iterative IR)

## 1. Clinical Intent & Operational Mechanics
3D Cone Beam Computed Tomography (CBCT) datasets generate complex multi-angle projections. The upstream RTX Pro 6000 handles the heavy mathematical voxel rendering, but manipulation of that 3D object requires the client node to stream massive volumetric updates. The ASUS TUF card uses its hardware-accelerated NVDEC (NVIDIA Video Decoder) engine to decompress this real-time stream, allowing doctors to fluidly rotate, slice, and zoom complex dental and orthopedic arches.

## 2. Infrastructure Setup & Executable Mapping
These settings optimize the hardware decompression pipeline directly through the Windows registry layer to eliminate CPU processing bottlenecks.

## 3. Configuration Steps
[Registry Editor] ➔ [Citrix GfxRender] ➔ [Enable Hardware AVC/H.265/AV1 Decoding]

### Registry Injection for Hardware Decompression
1. Open an Administrative Command Prompt or PowerShell terminal.
2. Execute the following commands to configure the Citrix display engine to offload all video decompression directly onto the ASUS TUF hardware chips:

```cmd
reg add "HKLM\SOFTWARE\WOW6432Node\Citrix\ICA Client\Engine\Configuration\Advanced\Modules\GfxRender" /v "UseHardwareDecoding" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\WOW6432Node\Citrix\ICA Client\Engine\Configuration\Advanced\Modules\GfxRender" /v "PreferAVC444" /t REG_DWORD /d 1 /f
```
*(Note: `PreferAVC444` forces 4:4:4 chroma subsampling, preventing color bleeding or gray-scale degradation across dense structural interfaces).*

### Enforce Performance-Grade Power Profiling
Consumer cards naturally downclock their processing speed during periods of low activity. Force the TUF card to maintain operational readiness:
1. Open the **NVIDIA Control Panel** ➔ **Manage 3D Settings** ➔ **Global Settings**.
2. Change **Power management mode** to **Prefer maximum performance**.
3. Click **Apply**.

## 4. Clinical Verification Workflow
1. Open the **Carestream 3D Viewer** module inside the VDI session.
2. Select a dense 3D facial or jaw bone reconstruction.
3. Click and drag the volume to rotate it rapidly in a circular pattern.
4. **Validation Threshold:** Open Task Manager (`Ctrl + Shift + Esc`) on the local endpoint. The **Video Decode** graph must show active utilization (15%–40%), confirming that the ASUS TUF card is successfully handling the real-time decompression workload.
