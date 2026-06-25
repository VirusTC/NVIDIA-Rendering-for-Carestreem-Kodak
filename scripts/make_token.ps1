# Run once during workstation staging to store the secret token securely
\$SecretToken = "VTC-ASUS-RTX50-SECURE-HANDSHAKE-TOKEN-2026"

cmdkey /generic:"VirusTC-API-Handshake" /user:"SystemNode" /pass:"\$SecretToken"
