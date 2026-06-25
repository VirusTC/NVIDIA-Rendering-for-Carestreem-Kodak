# Gather VirusTC events generated from workstation group policy tasks
$Events = Get-WinEvent -LogName Application | Where-Object { $_.Id -eq 40660 -or $_.Id -eq 40661 } -ErrorAction SilentlyContinue

# Format, parse variables into the HTML template grid slots, and output directly to IIS root
# Out-File -FilePath "C:\inetpub\wwwroot\index.html" -Encoding utf8
