<#
.SYNOPSIS
    VirusTC Monthly Executive Report Email Subscription Delivery Task.
    Automates conversion of the latest markdown data into an HTML email format for the CIO.
.DESCRIPTION
    Runs on the 1st of every month via Windows Task Scheduler. Parses the newest report asset,
    builds inline executive CSS framing, and handles secure SMTP transit.
#>

# --- SUBSCRIPTION CONFIGURATION MATRIX ---
$CioEmailAddress = "cio-office@hospital.local"
$SenderAddress   = "virustc-automation@hospital.local"
$SmtpServer      = "smtp.hospital.local"
$ReportDirectory = "C:\VirusTC_Reports"

Write-Output "[VirusTC SUBSCRIPTION] Locating latest monthly executive report asset..."

# Ensure directory context exists
if (-not (Test-Path $ReportDirectory)) {
    Write-Error "Target archive folder directory does not exist. Halting subscription task."
    Exit 1
}

# Fetch the newest generated report file in the repository
$LatestReportFile = Get-ChildItem -Path $ReportDirectory -Filter "Executive_Report_*.md" | 
                    Sort-Object LastWriteTime -Descending | 
                    Select-Object -First 1

if ($null -eq $LatestReportFile) {
    Write-Error "No compliance report files discovered inside repository path. Delivery aborted."
    Exit 1
}

Write-Output "Processing file target: $($LatestReportFile.FullName)"
$RawMarkdownContent = Get-Content -Path $LatestReportFile.FullName -Raw

# --- BASIC MARKDOWN REGEX CONVERSION RADIX ---
# This translates markdown elements into semantic HTML tags with inline styles for universal email client compatibility
$HtmlBodyContent = $RawMarkdownContent
$HtmlBodyContent = $HtmlBodyContent -replace '(?m)^# (.*)$', '<h1 style="color:#f8fafc; font-size:1.75rem; border-bottom:2px solid #334155; padding-bottom:0.5rem; margin-bottom:1.5rem;">$1</h1>'
$HtmlBodyContent = $HtmlBodyContent -replace '(?m)^## (.*)$', '<h2 style="color:#10b981; font-size:1.35rem; margin-top:1.5rem; margin-bottom:0.75rem;">$1</h2>'
$HtmlBodyContent = $HtmlBodyContent -replace '(?m)^### (.*)$', '<h3 style="color:#f1f5f9; font-size:1.05rem; margin-top:1rem; margin-bottom:0.5rem;">$1</h3>'
$HtmlBodyContent = $HtmlBodyContent -replace '(?m)^\* (.*)$', '<li style="margin-bottom:0.5rem; font-size:0.9rem; color:#cbd5e1;">$1</li>'
$HtmlBodyContent = $HtmlBodyContent -replace '(?m)^\*\*([^*]+)\*\*$', '<strong>$1</strong>'
$HtmlBodyContent = $HtmlBodyContent -replace '(?m)^---$', '<hr style="border:0; border-top:1px solid #334155; margin:1.5rem 0;" />'

# Convert text blocks wrapped in tri-backticks into clean pre-formatted technical code block elements
$HtmlBodyContent = $HtmlBodyContent -replace '(?s)```(.*?)```', '<pre style="background-color:#0f172a; padding:1rem; border-radius:6px; border:1px solid #334155; font-family:monospace; font-size:0.8rem; color:#94a3b8; overflow-x:auto; margin:1rem 0;">$1</pre>'

# --- MASTER EMAIL CONTAINER WRAPPER ---
$FinalEmailBody = @"
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
</head>
<body style="background-color:#0f172a; margin:0; padding:0; font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Helvetica,Arial,sans-serif;-webkit-text-size-adjust:none;-ms-text-size-adjust:none;">
    <table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-color:#0f172a; padding:2rem 0;">
        <tr>
            <td align="center">
                <table border="0" cellpadding="0" cellspacing="0" width="640" style="background-color:#1e293b; border:1px solid #334155; border-radius:8px; padding:2.5rem; text-align:left;">
                    <tr>
                        <td style="color:#f8fafc; font-size:0.95rem; line-height:1.6;">
                            $HtmlBodyContent
                        </td>
                    </tr>
                    <tr>
                        <td style="padding-top:2rem; border-top:1px solid #334155; margin-top:2rem; text-align:center; font-size:0.75rem; color:#64748b;">
                            This automated operational report was compiled and delivered by <strong>Virus Treatment Centers [VirusTC]</strong> infrastructure automation scripts. 
                            <br />To modify subscription parameters or recipients, update the GPO scheduled task options matrix.
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>
"@

# --- DELIVERY PIPELINE EXECUTOR ---
$SubjectDateStr = (Get-Date).AddMonths(-1).ToString("MMMM yyyy")
$EmailSubject   = "STAT INSIGHTS: Hospital Clinical Infrastructure Performance Report ($SubjectDateStr)"

$EmailParams = @{
    From       = $SenderAddress
    To         = $CioEmailAddress
    Subject    = $EmailSubject
    Body       = $FinalEmailBody
    BodyAsHtml = $true
    SmtpServer = $SmtpServer
    Priority   = "High"
}

try {
    Write-Output "Dispatching inline formatted delivery package payload directly to the CIO office channel..."
    Send-MailMessage @EmailParams -ErrorAction Stop
    Write-Output "[VirusTC SUBSCRIPTION COMPLETE] Executive report successfully dispatched to: $CioEmailAddress"
} catch {
    Write-Error "Critical delivery pipeline failure: $($_.Exception.Message)"
    Exit 2
}
