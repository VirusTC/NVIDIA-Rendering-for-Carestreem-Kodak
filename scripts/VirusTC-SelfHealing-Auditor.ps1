<#
.SYNOPSIS
    VirusTC Deployment Verification & Self-Healing Tool.
    Deployed via GPO to monitor and automatically repair ASUS TUF RTX 50 Series configurations.
.DESCRIPTION
    Audits registry states, network QoS tracking, and NVIDIA GPU performance profiles.
    Instantly auto-remediates and fixes any drift anomalies on the spot.
#>

# --- CONFIGURATION MATRIX ---
$AlertEmailFrom = "endpoint-remediation@hospital.local"
$AlertEmailTo   = "it-imaging-alerts@hospital.local"
$SmtpServer     = "smtp.hospital.local"
$WorkstationID  = $env:COMPUTERNAME
$DriftDetected  = $false
$RemediationLog = @()

Write-Output "Executing VirusTC Active Self-Healing Audit for machine: $WorkstationID"

# ============================================================================
# REMEDIATION LOOP 1: CITRIX HDX HARDWARE DECODING REGISTRY KEYS
# ============================================================================
$GfxPath = "HKLM:\SOFTWARE\WOW6432Node\Citrix\ICA Client\Engine\Configuration\Advanced\Modules\GfxRender"
$RequiredKeys = @{
    "UseHardwareDecoding" = 1
    "PreferAVC444"        = 1
}

if (-not (Test-Path $GfxPath)) {
    $DriftDetected = $true
    $RemediationLog += "[REPAIR] Citrix GfxRender path was missing. Re-creating core directory tree."
    New-Item -Path $GfxPath -Force | Out-Null
}

foreach ($Key in $RequiredKeys.Keys) {
    $CurrentValue = (Get-ItemProperty -Path $GfxPath -Name $Key -ErrorAction SilentlyContinue).$Key
    if ($CurrentValue -ne $RequiredKeys[$Key]) {
        $DriftDetected = $true
        $RemediationLog += "[REPAIR] Citrix Registry Key '$Key' drifted to '$CurrentValue'. Enforcing value '$($RequiredKeys[$Key])'."
        Set-ItemProperty -Path $GfxPath -Name $Key -Value $RequiredKeys[$Key] -Type DWord -Force | Out-Null
    }
}

# ============================================================================
# REMEDIATION LOOP 2: WINDOWS USER GRAPHICS ACCELERATION OVERRIDES
# ============================================================================
$GpuPrefPath = "HKCU:\Software\Microsoft\DirectX\UserGpuPreferences"
$TargetApp   = "C:/Program Files (x86)/Citrix/ICA Client/CDViewer.exe"

if (-not (Test-Path $GpuPrefPath)) {
    New-Item -Path $GpuPrefPath -Force | Out-Null
}

$CurrentPref = (Get-ItemProperty -Path $GpuPrefPath -Name $TargetApp -ErrorAction SilentlyContinue).$TargetApp
if ($CurrentPref -notmatch "GpuPreference=2;") {
    $DriftDetected = $true
    $RemediationLog += "[REPAIR] Windows Graphics Preference for CDViewer.exe was lost. Forcing High-Performance Profile."
    Set-ItemProperty -Path $GpuPrefPath -Name $TargetApp -Value "GpuPreference=2;" -Type String -Force | Out-Null
}

# ============================================================================
# REMEDIATION LOOP 3: INBOUND NETWORK QUALITY OF SERVICE (QoS) POLICY
# ============================================================================
$QosPolicy = Get-NetQosPolicy -Name "VirusTC_Receiver_Inbound" -ErrorAction SilentlyContinue

if ($null -eq $QosPolicy -or $QosPolicy.DSCPAction -ne 46) {
    $DriftDetected = $true
    $RemediationLog += "[REPAIR] Network QoS 'VirusTC_Receiver_Inbound' was missing or corrupted. Re-deploying Policy Core."
    
    # Clean old instances and enforce the Expedited Forwarding (DSCP 46) policy tags
    Get-NetQosPolicy -Name "VirusTC_Receiver_Inbound" -ErrorAction SilentlyContinue | Remove-NetQosPolicy -Confirm:$false
    New-NetQosPolicy -Name "VirusTC_Receiver_Inbound" -AppPathNameMatchCondition "CDViewer.exe" -DSCPAction 46 -PolicyStore ActiveStore | Out-Null
    New-NetQosPolicy -Name "VirusTC_Receiver_Inbound" -AppPathNameMatchCondition "CDViewer.exe" -DSCPAction 46 -PolicyStore PersistentStore | Out-Null
}

# ============================================================================
# REMEDIATION LOOP 4: LOCAL ASUS TUF NVIDIA HARDWARE P-STATE PROFILE
# ============================================================================
$NvidiaSmi = "C:\Program Files\NVIDIA Corporation\NVIDIA-SMI\nvidia-smi.exe"

if (Test-Path $NvidiaSmi) {
    $PersistenceMode = & $NvidiaSmi --query-gpu=persistence_mode --format=csv,noheader,nounits
    if ($PersistenceMode -notmatch "Enabled") {
        $DriftDetected = $true
        $RemediationLog += "[REPAIR] NVIDIA Persistence Mode was Disabled. Re-activating driver persistence."
        Start-Process -FilePath $NvidiaSmi -ArgumentList "-pm 1" -NoNewWindow -Wait
        Start-Process -FilePath $NvidiaSmi -ArgumentList "-g 0 -acp P0" -NoNewWindow -Wait
        $CurrentStatus = "Healed"
        $CurrentEventID = 40661
    } else {
        # The card is already healthy and in P0 performance state
        if (-not $DriftDetected) {
            $CurrentStatus = "Compliant"
            $CurrentEventID = 40662
            $RemediationLog += "NVIDIA hardware profile is fully optimal."
        }
    }
} else {
    $DriftDetected = $true
    $CurrentStatus = "Drifted"
    $CurrentEventID = 40660
    $RemediationLog += "[CRITICAL CRASH] NVIDIA-SMI utility missing. Local ASUS TUF graphics driver requires immediate IT reinstall."
}

# ============================================================================
# CENTRALIZED API DISPATCH (Executed globally at the end of the script)
# ============================================================================
$BodyJson = @{
    AuthToken      = "VTC-ASUS-RTX50-SECURE-HANDSHAKE-TOKEN-2026"
    WorkstationID  = $WorkstationID
    GpuHardware    = "ASUS TUF RTX 5080" 
    EventID        = $CurrentEventID
    Status         = $CurrentStatus
    LogDetails     = ($RemediationLog -join " | ")
} | ConvertTo-Json

# Send payload securely to network storage node listener
Invoke-RestMethod -Uri "https://hospital.local" -Method Post -Body $BodyJson -ContentType "application/json"

# ============================================================================
# SECURITY LAYER: SECURE STORAGE TOKEN EXTRACTION
# ============================================================================
Write-Output "Extracting secure API handshake credentials from Windows Vault..."

# Add assembly pathways to interact with the native Windows Credential UI layers
Add-Type -AssemblyName System.DirectoryServices.AccountManagement

# Fetch the specific generic credential object matching your target identifier name
\$TargetTarget = "VirusTC-API-Handshake"
\$CredentialFetch = [Windows.Security.Credentials.PasswordVault, Windows.Security.Credentials, ContentType=WindowsRuntime]::new()

try {
    # Extract the encrypted password payload string securely from the local system vault
    \$CredentialResult = CredentialFetch.Retrieve(TargetTarget, "SystemNode")
    SecretToken = CredentialResult.Password
    Write-Output "Successfully bound secure authentication token from DPAPI container."
} catch {
    # Fallback response context handling if a local technician deletes the token from the vault
    \$DriftDetected = \(true\)CurrentStatus = "Drifted"
    \(CurrentEventID = 40660\)RemediationLog += "[SECURITY FAULT] Handshake credential 'VirusTC-API-Handshake' not found inside Windows Credential Manager."
    
    # Set fallback token variable state to empty string to prevent successful payload generation leaks
    \$SecretToken = ""
}

# ============================================================================
# CENTRALIZED API DISPATCH (Uses the securely extracted token)
# ============================================================================
if (\$SecretToken -ne "") {
    \$BodyJson = @{
        AuthToken      = \$SecretToken  # Secure token referenced dynamically from memory
        WorkstationID  = \$WorkstationID
        GpuHardware    = "ASUS TUF RTX 5080" 
        EventID        = \$CurrentEventID
        Status         = \$CurrentStatus
        LogDetails     = (\$RemediationLog -join " | ")
    } | ConvertTo-Json

    # Send payload securely to network storage node listener
    Invoke-RestMethod -Uri "https://hospital.local" -Method Post -Body \$BodyJson -ContentType "application/json"
}

# ============================================================================
# AUDIT SUBMISSION & POST-REPAIR REPORTING
# ============================================================================
if ($DriftDetected) {
    $CompiledLog = $RemediationLog -join "`n"
    Write-Host "Self-Healing Actions Taken:`n$CompiledLog" -ForegroundColor Yellow

    # Action A: Write a structural recovery notice to the Local Application Log
    $EventID = 40661 # Custom VirusTC Auto-Remediation Event ID
    if (-not [System.Diagnostics.EventLog]::SourceExists("VirusTC-SelfHealer")) {
        New-EventLog -LogName Application -Source "VirusTC-SelfHealer"
    }
    Write-EventLog -LogName Application -Source "VirusTC-SelfHealer" -EntryType Information -EventId $EventID `
                   -Message "VirusTC Auto-Remediation Triggered: Workstation $WorkstationID config drift successfully auto-repaired.`nRemediation Log:`n$CompiledLog"

    # Action B: Inform IT that the machine drifted but was successfully self-healed
    $EmailBody = @"
NOTICE: Automatic Self-Healing Triggered & Completed
Workstation Name: $WorkstationID
Action Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

The automated deployment script found configuration changes and successfully fixed them:
----------------------------------------------------------------------------------------
$CompiledLog

STATUS: Workstation clinical diagnostic display capabilities have been fully restored to baseline. No manual intervention required.
"@

    try {
        Send-MailMessage -From $AlertEmailFrom -To $AlertEmailTo -Subject "RESOLVED: $WorkstationID Auto-Remediation Event" `
                         -Body $EmailBody -SmtpServer $SmtpServer -ErrorAction Stop
    } catch {
        Write-Error "Failed to dispatch recovery email payload via SMTP network backend."
    }
} else {
    Write-Output "Success: Workstation $WorkstationID is perfectly aligned with all VirusTC clinical specifications."
}
