# Infrastructure Automation: API Listener Extension for Automated Asset Archiving
**Path:** Integration patch for `scripts/VirusTC-API-Listener.ps1`  
**Deployment Context:** Replaces the internal JSON parsing block of the main server API script.

## 1. Functional Purpose
When a workstation is retired using the decommissioning scrub module, it sends a final status payload of `"Decommissioned"`. This update to your centralized API listener automatically captures that state, strips the active row entry from the operational dashboard table, and archives it into a hidden, collapsed auditing log layer at the bottom of the page. 

This keeps the main active fleet table clean while preserving required IT compliance history automatically.

---

## 2. Integrated Code Update (Replaces Inbound Payload Switch-Block)

Incorporate this updated block into your main **`scripts/VirusTC-API-Listener.ps1`** loop handler right after the authentication token verification step:

```powershell
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
```

---

## 3. Required Dashboard Additions (`dashboards/VirusTC-Compliance-Dashboard.html`)

To support this archiving feature, add this complementary data block to the very bottom of your dashboard file, right before the closing `</body>` tag:

```html
    <!-- HISTORICAL COMPLIANCE ARCHIVE ACCORDION SECTION -->
    <div class="table-section" style="margin-top: 2rem; border-color: rgba(51,65,85,0.4); opacity: 0.75;">
        <h2 style="color: var(--text-muted); font-size: 1rem;">Retired / Decommissioned Workstations Archive</h2>
        <table style="margin-top: 0.5rem;">
            <thead>
                <tr>
                    <th style="font-size: 0.8rem;">Asset ID</th>
                    <th style="font-size: 0.8rem;">Hardware Variant</th>
                    <th style="font-size: 0.8rem;">Removal Date</th>
                    <th style="font-size: 0.8rem;">Retirement Code</th>
                    <th style="font-size: 0.8rem;">Final Operational Audit Tracking Log Summary</th>
                </tr>
            </thead>
            <tbody>
                <!-- ARCHIVE_TARGET_MARKER -->
                <!-- Dynamic system archiving injection lane. Do not clear manually. -->
            </tbody>
        </table>
    </div>
```
