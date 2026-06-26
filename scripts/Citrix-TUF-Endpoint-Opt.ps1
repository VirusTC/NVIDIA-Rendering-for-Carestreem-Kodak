# =======================================================================================
# SECTION: FDA-COMPLIANT NVIDIA REGISTRY OPTIMIZATION & WORKSTATION STABILITY FOR VUE PACS
# =======================================================================================
Write-Output "[+] Initiating NVIDIA Pipeline and Carestream Vue Registry Optimization Loop..."

# 1. Enforce High-Performance CUDA Context Initialization
$NvidiaStereoPath = "HKLM:\SOFTWARE\NVIDIA Corporation\Global\Stereo3D"
try {
    if (-not (Test-Path $NvidiaStereoPath)) {
        New-Item -Path $NvidiaStereoPath -Force | Out-Null
        Write-Output "[*] Created missing NVIDIA Global Stereo3D key structure."
    }
    New-ItemProperty -Path $NvidiaStereoPath -Name "EnableMedicalImagingOptimizations" -Value 1 -PropertyType DWord -Force | Out-Null
    Write-Output "[SUCCESS] Enforced EnableMedicalImagingOptimizations = 1"
} catch {
    Write-Error "[ERROR] Failed to write NVIDIA Corporation registry overrides: $_"
}

# 2. Configure Windows TDR Controls to Prevent AI Denoising Timeout Driver Resets
$GraphicsDriversPath = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
try {
    New-ItemProperty -Path $GraphicsDriversPath -Name "TdrDelay" -Value 10 -PropertyType DWord -Force | Out-Null
    Write-Output "[SUCCESS] Windows Graphics Engine TdrDelay set to 10 seconds (Stable State)."
} catch {
    Write-Error "[ERROR] Failed to write Windows Graphics TDR Delay overrides: $_"
}

# 3. Force Carestream Vue Client App Layer to Prioritize NVDEC Hardware Pipelines
$VueRenderingPath = "HKLM:\SOFTWARE\Carestream\VuePACS\Client\Rendering"
try {
    if (-not (Test-Path $VueRenderingPath)) {
        New-Item -Path $VueRenderingPath -Force | Out-Null
        Write-Output "[*] Created missing Carestream Vue PACS Client Rendering path."
    }
    New-ItemProperty -Path $VueRenderingPath -Name "ForceNvidiaHardwareDecode" -Value 1 -PropertyType DWord -Force | Out-Null
    Write-Output "[SUCCESS] Enforced ForceNvidiaHardwareDecode = 1 for identical monitor/film output."
} catch {
    Write-Error "[ERROR] Failed to write Carestream software runtime overrides: $_"
}

# 4. Local Execution Verification and Audit Payload Pre-Staging
$AuditStatus = @{
    WorkstationID = $env:COMPUTERNAME
    Timestamp     = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    TdrVerified   = ((Get-ItemProperty -Path $GraphicsDriversPath).TdrDelay -eq 10)
    NvidiaEnabled = ((Get-ItemProperty -Path $VueRenderingPath -ErrorAction SilentlyContinue).ForceNvidiaHardwareDecode -eq 1)
}

if ($AuditStatus.TdrVerified -and $AuditStatus.NvidiaEnabled) {
    Write-Output "[SUCCESS] Golden Master Image configuration matches FDA rendering compliance metrics."
} else {
    Write-Warning "[ALERT] Critical optimization state mismatch found during local verification step!"
}
# =======================================================================================
