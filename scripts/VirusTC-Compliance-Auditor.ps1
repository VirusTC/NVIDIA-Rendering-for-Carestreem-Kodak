<#
.SYNOPSIS
    VirusTC Deployment Verification Tool - Endpoint Drift Auditor.
    Deployed via GPO to monitor ASUS TUF RTX 50 Series Workspace compliance.
.DESCRIPTION
    Audits registry states, network QoS tracking, and NVIDIA GPU performance profiles.
    Generates structured system alerts if a configuration drifts from target metrics.
#>

# --- CONFIGURATION MATRIX ---
$AlertEmailFrom = "endpoint-audit@hospital.local"
$AlertEmailTo   = "it-imaging-alerts@hospital.local"
$SmtpServer     = "smtp.hospital.local"
$WorkstationID  = $env:COMPUTERNAME
$DriftDetected  = $false
$DriftReport    = @()

Write-Output "Executing VirusTC Workspace Compliance Audit for machine: $WorkstationID"

# ============================================================================
# AUDIT 1: CITRIX HDX HARDWARE DECODING REGISTRY KEYS
# ============================================================================
$GfxPath = "HKLM:\SOFTWARE\WOW6432Node\Citrix\ICA Client\Engine\Configuration\Advanced\Modules\GfxRender"

$RequiredKeys = @{
    "UseHardwareDecoding" = 1
    "PreferAVC444"        = 1
}

foreach ($Key in $RequiredKeys.Keys) {
    if (Test-Path $GfxPath) {
        $CurrentValue = (Get-ItemProperty -Path $GfxPath -Name $Key -ErrorAction SilentlyContinue).$Key
        if ($CurrentValue -ne $RequiredKeys[$Key]) {
            $DriftDetected = $true
            $DriftReport += "[DRIFT] Citrix Registry Key '$Key' is set to '$CurrentValue' (Expected: $($RequiredKeys[$Key]))"
        }
    } else {
        $DriftDetected = $true
        $DriftReport += "[CRITICAL] Citrix GfxRender path missing completely from registry hierarchy."
        break
    }
}

# ============================================================================
# AUDIT 2: WINDOWS USER GRAPHICS ACCELERATION OVERRIDES
# ============================================================================
$GpuPrefPath = "HKCU:\Software\Microsoft\DirectX\UserGpuPreferences"
$TargetApp   = "C:/Program Files (x86)/Citrix/ICA Client/CDViewer.exe"

if (Test-Path $GpuPrefPath) {
    $CurrentPref = (Get-ItemProperty -Path $GpuPrefPath -Name $TargetApp -ErrorAction SilentlyContinue).$TargetApp
    if ($CurrentPref -notmatch "GpuPreference=2;") {
        $DriftDetected = $true
        $DriftReport += "[DRIFT] Windows Graphics Preference for CDViewer.exe is misconfigured (Expected: High Performance / GpuPreference=2;)"
    }
} else {
    $DriftDetected = $true
    $DriftReport += "[DRIFT] UserGpuPreferences path missing. Defaulting to integrated scheduling."
}

# ============================================================================
# AUDIT 3: INBOUND NETWORK QUALITY OF SERVICE (QoS) POLICY
# ============================================================================
$QosPolicy = Get-NetQosPolicy -Name "VirusTC_Receiver_Inbound" -ErrorAction SilentlyContinue

if ($null -eq $QosPolicy) {
    $DriftDetected = $true
    $DriftReport += "[DRIFT] Network QoS Packet Tagging Policy 'VirusTC_Receiver_Inbound' was deleted or not deployed."
} elseif ($QosPolicy.DSCPAction -ne 46) {
    $DriftDetected = $true
    $DriftReport += "[DRIFT] Network QoS DSCP Value has drifted to '$($QosPolicy.DSCPAction)' (Expected: 46 Expedited Forwarding)"
}

# ============================================================================
# AUDIT 4: LOCAL ASUS TUF NVIDIA HARDWARE P-STATE PROFILE
# ============================================================================
$NvidiaSmi = "C:\Program Files\NVIDIA Corporation\NVIDIA-SMI\nvidia-smi.exe"

if (Test-Path $NvidiaSmi) {
    # Query Persistence Mode via native NVML CLI
    $PersistenceMode = & $NvidiaSmi --query-gpu=persistence_mode --format=csv,noheader,nounits
    if ($PersistenceMode -notmatch "Enabled") {
        $DriftDetected = $true
        $DriftReport += "[DRIFT] NVIDIA Persistence Mode is Disabled (Expected: Enabled for instant wake times)"
    }
} else {
    $DriftDetected = $true
    $DriftReport += "[CRITICAL] NVIDIA-SMI utility missing. Local ASUS TUF graphics driver may be corrupted or uninstalled."
}

# ============================================================================
# REGISTRATION & RESPONSE HANDLER
# ============================================================================
if ($DriftDetected) {
    $CompiledReport = $DriftReport -join "`n"
    Write-Warning "Configuration Drift Detected!`n$CompiledReport"

    # Action A: Write a structured event log warning into Application log for SIEM capture
    $EventID = 40660 # Custom VirusTC Clinical Infrastructure Audit Event ID
    if (-not [System.Diagnostics.EventLog]::SourceExists("VirusTC-Auditor")) {
        New-EventLog -LogName Application -Source "VirusTC-Auditor"
    }
    Write-EventLog -LogName Application -Source "VirusTC-Auditor" -EntryType Warning -EventId $EventID `
                   -Message "VirusTC Compliance Warning: Workstation $WorkstationID has drifted from clinical imaging specifications.`nDetails:`n$CompiledReport"

    # Action B: Dispatch an alert email directly to the Clinical Systems Helpdesk
    $EmailBody = @"
ALERT: Clinical Imaging Endpoint Optimization Drift Detected
Workstation Name: $WorkstationID
Audit Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

The following configuration anomalies were discovered during the automated GPO check-in:
----------------------------------------------------------------------------------------
$CompiledReport

ACTION REQUIRED: Re-deploy the master VirusTC deployment configuration package to this node to restore diagnostic imaging fidelity.
"@

    try {
        Send-MailMessage -From $AlertEmailFrom -To $AlertEmailTo -Subject "CRITICAL DRIFT: $WorkstationID Optimization Error" `
                         -Body $EmailBody -SmtpServer $SmtpServer -ErrorAction Stop
    } catch {
        Write-Error "Failed to dispatch drift alert email payload via SMTP backend."
    }
} else {
    Write-Output "Success: Workstation $WorkstationID is fully compliant with all VirusTC clinical specifications."
}
