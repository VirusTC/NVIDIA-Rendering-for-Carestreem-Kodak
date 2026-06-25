# Infrastructure Automation: Master PVS/MCS Image Optimization Script
**Path:** `scripts/Citrix-TUF-Endpoint-Optimization.ps1`  
**Deployment Context:** Run within the Golden Master Image prior to PVS/MCS catalog sealing.

## 1. Functional Purpose
This script automates local registry modifications, network-layer configurations, and hardware state pinning directly on endpoint virtual desktops. It forces guest operating systems to route VDI display decodes directly through the **ASUS TUF GeForce RTX 50 Series** hardware pipelines rather than using host CPU resources.

## 2. Core Code Execution
```powershell
<#
.SYNOPSIS
    Citrix Master Image Sealing Extension: ASUS TUF GeForce RTX 50 Series Client Optimization.
    Designed for VirusTC Network Infrastructure deployments.
.DESCRIPTION
    Automates Windows Registry overrides for Citrix HDX hardware decoding, injects Network QoS 
    Expedited Forwarding tags, and configures local NVIDIA driver P-States for remote doctors' offices.
.NOTES
    Run this script with elevated Administrative Privileges prior to sealing the image via PVS/MCS.
#>

\$LogPath = "C:\Program Files\Carestream\Logs\VirusTC_Endpoint_Optimization.log"
Start-Transcript -Path \$LogPath -Append

Write-Output "[VirusTC START] Initializing ASUS TUF RTX 50 Series VDI Endpoint Optimizations..."

# ============================================================================
# 1. CITRIX HDX HARDWARE DECODING REGISTRY OVERRIDES
# ============================================================================
Write-Output "[1/4] Injecting Citrix GfxRender Hardware Acceleration Keys..."

\$CitrixRegPath = "HKLM:\SOFTWARE\WOW6432Node\Citrix\ICA Client\Engine\Configuration\Advanced\Modules\GfxRender"

if (-not (Test-Path \$CitrixRegPath)) {
    New-Item -Path \$CitrixRegPath -Force | Out-Null
}

# Force hardware decoding offload onto NVDEC chip
Set-ItemProperty -Path \$CitrixRegPath -Name "UseHardwareDecoding" -Value 1 -Type DWord -Force
# Enforce AVC 4:4:4 Chroma Subsampling for flawless color/grayscale reproduction
Set-ItemProperty -Path \$CitrixRegPath -Name "PreferAVC444" -Value 1 -Type DWord -Force

# Force Citrix hooking engine to tightly bind acceleration to core UI rendering files
\$HookPath = "HKLM:\SOFTWARE\Citrix\CtxHook\Appops\CitrixWorkspace"
if (-not (Test-Path HookPath)) New-Item -Path HookPath -Force | Out-Null }
Set-ItemProperty -Path \$HookPath -Name "Name" -Value "wfica32.exe" -Type String -Force
Set-ItemProperty -Path \$HookPath -Name "Flag" -Value 0x00000020 -Type DWord -Force

# ============================================================================
# 2. WINDOWS GRAPHICS PERFORMANCE POLICY INJECTION
# ============================================================================
Write-Output "[2/4] Setting Windows OS High Performance GPU Preference for Citrix App Packages..."

\$AppsToOptimize = @(
    "C:\Program Files (x86)\Citrix\ICA Client\wfica32.exe",
    "C:\Program Files (x86)\Citrix\ICA Client\CDViewer.exe"
)

foreach (App in AppsToOptimize) {
    if (Test-Path \$App) {
        AppRegName = App.Replace("\", "/")
        \$WinGraphicsPath = "HKCU:\Software\Microsoft\DirectX\UserGpuPreferences"
        if (-not (Test-Path WinGraphicsPath)) New-Item -Path WinGraphicsPath -Force | Out-Null }
        Set-ItemProperty -Path WinGraphicsPath -Name AppRegName -Value "GpuPreference=2;" -Type String -Force
        Write-Output "Successfully mapped \$App to OS High-Performance profile."
    } else {
        Write-Warning "Target Citrix executable path not found: \$App. Skipping OS mapping."
    }
}

# ============================================================================
# 3. NETWORK LAYER QUALITY OF SERVICE (QoS) POLICIES
# ============================================================================
Write-Output "[3/4] Provisioning Network QoS Policies for Inbound Imaging Bitstreams..."

Get-NetQosPolicy -Name "VirusTC_Receiver_Inbound" -ErrorAction SilentlyContinue | Remove-NetQosPolicy -Confirm:\$false

New-NetQosPolicy -Name "VirusTC_Receiver_Inbound" `
                 -AppPathNameMatchCondition "CDViewer.exe" `
                 -DSCPAction 46 `
                 -PolicyStore ActiveStore | Out-Null

New-NetQosPolicy -Name "VirusTC_Receiver_Inbound" `
                 -AppPathNameMatchCondition "CDViewer.exe" `
                 -DSCPAction 46 `
                 -PolicyStore PersistentStore | Out-Null

# ============================================================================
# 4. LOCAL NVIDIA GEFORCE PERSISTENCE MODE & POWER PROFILING
# ============================================================================
Write-Output "[4/4] Optimizing Local ASUS TUF Power Profiles via NVIDIA-SMI Command Line..."

\$NvidiaSmiPath = "C:\Program Files\NVIDIA Corporation\NVIDIA-SMI\nvidia-smi.exe"

if (Test-Path \$NvidiaSmiPath) {
    Start-Process -FilePath \$NvidiaSmiPath -ArgumentList "-pm 1" -NoNewWindow -Wait
    Start-Process -FilePath \$NvidiaSmiPath -ArgumentList "-g 0 -acp P0" -NoNewWindow -Wait
    Write-Output "NVIDIA-SMI successfully locked GPU power state into Maximum Performance."
} else {
    Write-Warning "NVIDIA-SMI executable not found. Ensure NVIDIA Studio/Game Ready Driver is integrated."
}

Write-Output "[VirusTC COMPLETE] PVS/MCS Master Deployment Script optimization sequence finalized."
Stop-Transcript
```
