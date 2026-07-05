# Run this on your WINDOWS HOST (not inside the dev container / WSL).
#
# Usage (PowerShell): .\scripts\flash-windows.ps1 build\src\pico2_blink.uf2
#
# Put the Pico in BOOTSEL mode first:
#   hold the BOOTSEL button, plug in USB, then release BOOTSEL.
# It will appear as a removable drive named RP2350 (or similar).

param(
    [Parameter(Mandatory=$true)]
    [string]$Uf2Path
)

if (-not (Test-Path $Uf2Path)) {
    Write-Error "File not found: $Uf2Path"
    exit 1
}

# Find a removable drive that looks like the Pico's mass storage volume
$drive = Get-Volume | Where-Object {
    $_.DriveType -eq 'Removable' -and ($_.FileSystemLabel -eq 'RP2350' -or $_.FileSystemLabel -eq 'RPI-RP2')
} | Select-Object -First 1

if (-not $drive) {
    Write-Host "Could not auto-detect the Pico's drive."
    Write-Host "Make sure the Pico is in BOOTSEL mode (hold BOOTSEL while plugging in USB),"
    Write-Host "then check File Explorer for a drive named RP2350 or RPI-RP2, and run:"
    Write-Host "  Copy-Item `"$Uf2Path`" -Destination `"<DriveLetter>:\`""
    exit 1
}

$dest = "$($drive.DriveLetter):\"
Write-Host "Copying $Uf2Path to $dest ..."
Copy-Item $Uf2Path -Destination $dest
Write-Host "Done. The Pico should reboot and start running the new program."
