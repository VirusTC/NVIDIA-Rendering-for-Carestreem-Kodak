# Construct and execute the decommissioning payload notification 
$ScrubPayloadJson = @{
    AuthToken      = "VTC-ASUS-RTX50-SECURE-HANDSHAKE-TOKEN-2026"
    WorkstationID  = $WorkstationID
    GpuHardware    = "ASUS TUF RTX 5080"
    EventID        = 40662
    Status         = "Decommissioned"
    LogDetails     = "Asset scrub protocol executed. Credentials wiped. QoS deleted. Device unassigned from clinical fleet."
} | ConvertTo-Json

Invoke-RestMethod -Uri "https://hospital.local" -Method Post -Body $ScrubPayloadJson -ContentType "application/json"
