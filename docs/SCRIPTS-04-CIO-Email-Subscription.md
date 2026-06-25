# Infrastructure Automation: Automated CIO Email Subscription Dispatcher
**Path:** `scripts/VirusTC-Monthly-Email-Subscription.ps1`  
**Deployment Context:** Run on the 1st day of each month at 06:00 AM via Windows Task Scheduler.

## 1. Functional Purpose
This script reads the most recent Markdown file from the local server directory, converts its structures into semantic HTML blocks with inline CSS styles, and emails the compiled document to the hospital's Chief Information Officer (CIO).

## 2. Core Code Execution
```powershell
\$CioEmailAddress = "cio-office@hospital.local"
\$SenderAddress   = "virustc-automation@hospital.local"
\$SmtpServer      = "smtp.hospital.local"
\$ReportDirectory = "C:\VirusTC_Reports"

LatestReportFile = Get-ChildItem -Path ReportDirectory -Filter "Executive_Report_*.md" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if (null -eq LatestReportFile) { Exit 1 }

\$RawMarkdownContent = Get-Content -Path \(LatestReportFile.FullName -Raw\)HtmlBodyContent = \(RawMarkdownContent\)HtmlBodyContent = \(HtmlBodyContent -replace '(?m)^# (.*)\)', '<h1 style="color:#f8fafc; font-size:1.75rem; border-bottom:2px solid #334155; padding-bottom:0.5rem; margin-bottom:1.5rem;">\(1</h1>'\)HtmlBodyContent = \(HtmlBodyContent -replace '(?m)^## (.*)\)', '<h2 style="color:#10b981; font-size:1.35rem; margin-top:1.5rem; margin-bottom:0.75rem;">\(1</h2>'\)HtmlBodyContent = \(HtmlBodyContent -replace '(?m)^\* (.*)\)', '<li style="margin-bottom:0.5rem; font-size:0.9rem; color:#cbd5e1;">\$1</li>'
HtmlBodyContent = HtmlBodyContent -replace '(?s)```(.*?)```', '<pre style="background-color:#0f172a; padding:1rem; border-radius:6px; border:1px solid #334155; font-family:monospace; font-size:0.8rem; color:#94a3b8;">\$1</pre>'

\(FinalEmailBody = "<html><body style='background-color:#0f172a; padding:2rem;'><table width='640' style='background-color:#1e293b; border-radius:8px; padding:2.5rem;'><tr><td>\)HtmlBodyContent</td></tr></table></body></html>"

\(EmailParams = @{ From =\)SenderAddress; To = CioEmailAddress; Subject = "STAT INSIGHTS: Infrastructure Report"; Body = FinalEmailBody; BodyAsHtml = true; SmtpServer = SmtpServer; Priority = "High" }
Send-MailMessage @EmailParams
```
