<#
.SYNOPSIS
    VirusTC Centralized REST API Listener Service.
    Receives secure inbound JSON compliance logs from VDI endpoints and updates the dashboard.
.DESCRIPTION
    Listens on port 8443 (HTTPS recommended). Validates security tokens, parses logs, 
    and writes state updates directly into the static HTML dashboard table matrix.
#>

$LogPath = "C:\inetpub\wwwroot\Logs\VirusTC_API_Listener.log"
$DashboardPath = "C:\inetpub\wwwroot\index.html"
$SecretToken = "VTC-ASUS-RTX50-SECURE-HANDSHAKE-TOKEN-2026" # Enforce cluster authorization matching

# Initialize HTTP Listener pipeline
$HttpListener = New-Object System.Net.HttpListener
$HttpListener.Prefixes.Add("https://+:8443/compliance/")
try {
    $HttpListener.Start()
    Write-Output "[VirusTC API] Security Listener online and binding tightly to port 8443..."
} catch {
    Write-Error "Failed to bind port. Ensure process runs as administrator and certificate is bound."
    Exit 1
}

# Continuous loop processing requests asynchronously 
while ($HttpListener.IsListening) {
    $Context = $HttpListener.GetContext()
    $Request = $Context.Request
    $Response = $Context.Response

    if ($Request.HttpMethod -eq "POST") {
        # Read payload stream buffer safely
        $Reader = New-Object System.IO.StreamReader($Request.InputStream)
        $RawJson = $Reader.ReadToEnd()
        $Payload = ConvertFrom-Json $RawJson -ErrorAction SilentlyContinue

        # Authentication check against internal enterprise cluster token
        if ($null -eq $Payload -or $Payload.AuthToken -ne $SecretToken) {
            $Response.StatusCode = 401 # Unauthorized
            $Buffer = [System.Text.Encoding]::UTF8.GetBytes("Authentication Failed: Invalid Node Token.")
            $Response.OutputStream.Write($Buffer, 0, $Buffer.Length)
            $Response.Close()
            Continue
        }

# ============================================================================
# EXTENDED PROCESSING: REMEDIATION, DRIFT, AND DECOMMISSION HANDLER
# ============================================================================
WorkstationID = Payload.WorkstationID
GpuHardware = Payload.GpuHardware
EventID = Payload.EventID
StatusStr = Payload.Status # Expecting: Compliant, Healed, Drifted, or Decommissioned
LogDetails = Payload.LogDetails

# Extract baseline file payload configuration states
HtmlContent = Get-Content -Path DashboardPath -Raw

if (\$StatusStr -eq "Decommissioned") {
    Write-Output "[VirusTC API] Intercepted retirement signal from node: \$WorkstationID. Initializing auto-archive protocol..."

    # Step A: Identify and slice out the active row profile element if it currently populates the datagrid
    if (\$HtmlContent -match "<!-- ROW_\(WorkstationID -->.*?<!-- /ROW_\)WorkstationID -->") {
        # Extract the raw row body context to move it into historical logging records
        \$HtmlContent -match "<!-- ROW_\(WorkstationID -->(.*?)<!-- /ROW_\)WorkstationID -->" | Out-Null
        ExtractedRowText = Matches[1]
        
        # Strip out styling markers and wrap inside a retro-fitted historical data trace row layout
        \$ArchivedRowHtml = "<!-- ARCHIVE_WorkstationID --><tr><td><span style='color:var(--text-muted); text-decoration:line-through;'>WorkstationID</span></td><td>GpuHardware</td><td>(Get-Date -Format 'yyyy-MM-dd')</td><td><span class='badge' style='background-color:rgba(148,163,184,0.15); color:var(--text-muted);'>Archived</span></td><td><div class='log-box'>\(LogDetails</div></td></tr><!-- /ARCHIVE_\)WorkstationID -->"

        # Step B: Remove the active row completely from the main operational overview segment
        HtmlContent = HtmlContent -replace "<!-- ROW_\(WorkstationID -->.*?<!-- /ROW_\)WorkstationID -->", ""
        
        # Step C: Append the archived layout matrix inside the designated audit tracking section container
        if (\$HtmlContent -match "<!-- ARCHIVE_TARGET_MARKER -->") {
            HtmlContent = HtmlContent -replace "<!-- ARCHIVE_TARGET_MARKER -->", "<!-- ARCHIVE_TARGET_MARKER -->`n$ArchivedRowHtml"
        }
    }
} else {
    # --- STANDARD FLEET MONITORED UPDATE PATHWAY ---
    switch ($StatusStr) {
        "Compliant" { $Badge = "<span class='badge badge-compliant'>Fully Compliant</span>" }
        "Healed"    { $Badge = "<span class='badge badge-healed'>Self-Healed</span>" }
        "Drifted"   { $Badge = "<span class='badge badge-drifted'>Drift / Error</span>" }
    }

    $NewRowHtml = "<tr><td><strong>$WorkstationID</strong></td><td>$GpuHardware</td><td>Event $EventID</td><td>$Badge</td><td><div class='log-box'>$LogDetails</div></td></tr>"
    
    if ($HtmlContent -match "<!-- ROW_$WorkstationID -->.*?<!-- /ROW_$WorkstationID -->") {
        $HtmlContent = $HtmlContent -replace "<!-- ROW_$WorkstationID -->.*?<!-- /ROW_$WorkstationID -->", "<!-- ROW_$WorkstationID -->$NewRowHtml<!-- /ROW_$WorkstationID -->"
    } else {
        $HtmlContent = $HtmlContent -replace "<tbody>", "<tbody>`n<!-- ROW_\$WorkstationID -->\(NewRowHtml<!-- /ROW_\)WorkstationID -->"
    }
}

# Dynamic timestamp compilation pass
\$CurrentTimeStr = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
HtmlContent = HtmlContent -replace '<span id="timestamp".*?>(.*?)</span>', "<span id=`"timestamp`" style=`"color: var(--text-main); font-weight: bold;`">\$CurrentTimeStr</span>"

# Save update states to the local IIS production document root folder path
HtmlContent | Out-File -FilePath DashboardPath -Encoding utf8 -Force

        # --- PROCESS ENTRY & REWRITE HTML GRID LAYER ---
        $WorkstationID = $Payload.WorkstationID
        $GpuHardware   = $Payload.GpuHardware
        $EventID       = $Payload.EventID
        $StatusStr     = $Payload.Status # Expecting: Compliant, Healed, or Drifted
        $LogDetails    = $Payload.LogDetails

        # Format HTML badge elements programmatically based on state
        switch ($StatusStr) {
            "Compliant" { $Badge = "<span class='badge badge-compliant'>Fully Compliant</span>" }
            "Healed"    { $Badge = "<span class='badge badge-healed'>Self-Healed</span>" }
            "Drifted"   { $Badge = "<span class='badge badge-drifted'>Drift / Error</span>" }
        }

        # Critical Section: Update the local index.html row matching the WorkstationID token safely
        $HtmlContent = Get-Content -Path $DashboardPath -Raw
        
        # Build clean dynamic row replacement block string patterns
        $NewRowHtml = "<tr><td><strong>$WorkstationID</strong></td><td>$GpuHardware</td><td>Event $EventID</td><td>$Badge</td><td><div class='log-box'>$LogDetails</div></td></tr>"
        
        # Simple string target injection pattern for prototype scaling
        if ($HtmlContent -match "<!-- ROW_$WorkstationID -->.*?<!-- /ROW_$WorkstationID -->") {
            $HtmlContent = $HtmlContent -replace "<!-- ROW_$WorkstationID -->.*?<!-- /ROW_$WorkstationID -->", "<!-- ROW_$WorkstationID -->$NewRowHtml<!-- /ROW_$WorkstationID -->"
        } else {
            # Append new entry if row structure does not exist natively yet inside target table
            $HtmlContent = $HtmlContent -replace "<tbody>", "<tbody>`n<!-- ROW_\$WorkstationID -->\(NewRowHtml<!-- /ROW_\)WorkstationID -->"
        }

        # Update last scrape timestamp value placeholder matching standard dashboard architecture
        \$CurrentTimeStr = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        HtmlContent = HtmlContent -replace '<span id="timestamp".*?>(.*?)</span>', "<span id=`"timestamp`" style=`"color: var(--text-main); font-weight: bold;`">\$CurrentTimeStr</span>"

        HtmlContent | Out-File -FilePath DashboardPath -Encoding utf8 -Force

        # Acknowledge successful data state ingestion back to node
        \$Response.StatusCode = 200 # OK
        \$Buffer = [System.Text.Encoding]::UTF8.GetBytes("Payload Committed Successfully to VirusTC Core Server Grid.")
        \$Response.OutputStream.Write(Buffer, 0, Buffer.Length)
    } else {
        \$Response.StatusCode = 405 # Method Not Allowed
    }
    \$Response.Close()
}
