###########################################################################
# Add drives to new Windows Server builds
# Author: Tom Meer
# Creation Date: 18/03/19
# Last Update Date: 
###########################################################################

# Read parameters
Param([int] $position, [string] $driveLetter, [string] $driveLabel, [float] $size, [string] $sizeUnit, [string] $unitAllocation)

# Write out parameters
Write-Host "[PARAMETER] Drive letter: $driveLetter"

# Convert any GB values to MB
if ($sizeUnit -eq "GB" ) {
    Write-Host "[PARAMETER] Size in GB: $size GB"
    $size = ($size*1GB)/1MB
    Write-Host "[PARAMETER] Size in MB: $size MB"
}

# Check PowerShell version
$psVer = (Get-Host).Version.Major
if ($psVer -lt 3) {
    Write-Host "[ERROR 20] PowerShell version is below 3, please do manually: $psVer"
    exit 1
}

# Import storage modules
Import-Module Storage -ErrorAction SilentlyContinue

# Get OS version as 2008/2008 R2 are annoying as hell and dont have proper storage modules
$osName = (Get-WmiObject Win32_OperatingSystem).Caption
if ($osName -like "*2008*") {
    $osVer = 2008
}

# Add new drive
Write-Host "[PARAMETER] New drive position: $position"
Write-Host "[PARAMETER] New drive size: $size MB"
Write-Host "[PARAMETER] New drive label: $driveLabel"
Write-Host "[PARAMETER] 64k allocation unit: $unitAllocation"

# Check if drive letter already in use
switch ($osVer) {
    2008 { $checkVolume = Get-WmiObject Win32_Volume | Where-Object {$_.DriveLetter -eq ($driveLetter + ":")} }
    default { $checkVolume = Get-Volume | Where-Object {$_.DriveLetter -eq $driveLetter} }
}
if ($checkVolume) {
    Write-Host "[ERROR 30] Drive letter already exists: $driveLetter"
    exit 1
}

# Check and get empty disk
switch ($osVer) {
    2008 { $newDisk = Get-WmiObject Win32_DiskDrive | Where-Object {$_.Partitions -eq 0} | Where-Object {$_.index -eq $position} }
    default {$newDisk = Get-Disk -Number $position | Where-Object {$_.PartitionStyle -eq "RAW"} }
}
if (-not $newDisk) {
    Write-Host "[ERROR 50] No RAW disk available at position: $position"
    exit 1
}

# Initalise disk as GPT and create volume
switch ($osVer) {
    2008 {
        $diskID = $newDisk.index
        Write-Host "[INFO] Empty disk with ID $diskID found, running diskpart..."
        "rescan `n select disk $diskID `n online disk noerr `n convert gpt `n create partition primary `n assign letter=$driveLetter `n format fs=ntfs label=`"$driveLabel`" quick" | diskpart
    }
    default {
        Write-Host "[INFO] RAW disk found, initialising..."
        Initialize-Disk $newDisk.Number -PartitionStyle "GPT"
        Write-Host "[INFO] Creating new volume: $driveLetter"
        New-Partition $newDisk.Number -DriveLetter $driveLetter -UseMaximumSize
        Write-Host "[INFO] Formatting new volume: $driveLetter"
        Format-Volume -DriveLetter $driveLetter -FileSystem "NTFS" -NewFileSystemLabel $driveLabel -Confirm:$false
        if ($unitAllocation -eq "yes") {
            Format-Volume -DriveLetter $driveLetter -FileSystem "NTFS" -AllocationUnitSize 65536 -NewFileSystemLabel $driveLabel -Confirm:$false
        }
    }
}

# Check if succesfully created new volume
Start-Sleep -s 10
switch ($osVer) {
    2008 { $newVolume = Get-WmiObject Win32_LogicalDisk | Where-Object {$_.DeviceID -eq ($driveLetter + ":")} }
    default { $newVolume = Get-Volume | Where-Object {$_.DriveLetter -eq $driveLetter} }
}
if (-not $newVolume) {
    Write-Host "[ERROR 60] New volume not created: $driveLetter"
    exit 1
}
Write-Host "[SUCCESS] New volume created: $driveLetter"
$newSize = [math]::round($newVolume.Size /1Mb, 0)
Write-Host "[SUCCESS] New volume size: $newSize MB"

# Exit with success
exit 0