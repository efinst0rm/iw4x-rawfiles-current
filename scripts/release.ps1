# Window Title
(Get-Host).UI.RawUI.WindowTitle = "Release Script: iw4x-rawfiles"

# Set the progress preference so that no blue progress bars appear in the console when running Compress-Archive cmdlets.
${global:ProgressPreference} = "SilentlyContinue"

# Grab the parent directory of the .ps1 script, regardless of the working directory you run the script from. This should 
# grab the full path to the iw4x-rawfiles directory, assuming this script is in the iw4x-rawfiles\scripts directory.
${rawFilesPath} = (Get-Item ${PSScriptRoot}).parent.FullName

# Create folders used for the release.
if (!(Test-Path -Path "${rawFilesPath}\release")) {
    [void](New-Item "${rawFilesPath}\release" -ItemType Directory)
}

if (Test-Path -Path "${rawFilesPath}\release\temp") {
    Remove-Item -Recurse -Force "${rawFilesPath}\release\temp"
}

[void](New-Item "${rawFilesPath}\release\temp" -ItemType Directory)

# Copy executables, iw4x files, and zone files to the temp folder.
Write-Host "Copying executables to ${rawFilesPath}\release\temp..."
Copy-Item -Path "${rawFilesPath}\iw4sp.exe" -Destination "${rawFilesPath}\release\temp\iw4sp.exe"
Copy-Item -Path "${rawFilesPath}\iw4x.exe" -Destination "${rawFilesPath}\release\temp\iw4x.exe"
Write-Host "Done copying executable files.`n"

Write-Host "Copying files to ${rawFilesPath}\release\temp\iw4x..."
Copy-Item -Path "${rawFilesPath}\iw4x" -Destination "${rawFilesPath}\release\temp\iw4x" -Recurse
Write-Host "Done copying iw4x files.`n"

Write-Host "Copying files to ${rawFilesPath}\release\temp\zone..."
Copy-Item -Path "${rawFilesPath}\zone" -Destination "${rawFilesPath}\release\temp\zone" -Recurse
Write-Host "Done copying zone files.`n"

# Create iw4x_00.iwd
for ($i = 0; $i -lt 6; $i++)
{ 
    ${archName} = ("iw4x_{0:D2}" -f $i)
    Write-Host "Compressing ${archName}.zip..."
    Compress-Archive -Path "${rawFilesPath}\release\temp\iw4x\${archName}\*" -DestinationPath "${rawFilesPath}\release\temp\iw4x\${archName}.zip"
    Write-Host "Renaming ${archName}.zip to ${archName}.iwd..."
    Move-Item -Path "${rawFilesPath}\release\temp\iw4x\${archName}.zip" -Destination "${rawFilesPath}\release\temp\iw4x\${archName}.iwd"
    Write-Host "Cleaning up ${archName} directory..."
    Remove-Item -Recurse "${rawFilesPath}\release\temp\iw4x\${archName}"
    Write-Host "Finished compressing ${archName}.iwd`n"
}

# Create release.zip
if (Test-Path -Path "${rawFilesPath}\release\release.zip") {
    Write-Host "Cleaning up old release.zip..."
    Remove-Item "${rawFilesPath}\release\release.zip"
}

Write-Host "Compressing release.zip..."
Compress-Archive -Path "${rawFilesPath}\release\temp\*" -DestinationPath "${rawFilesPath}\release\release.zip"
Write-Host "Finished compressing release.zip`n"

# Clean up temp directory
Write-Host "Cleaning up temp directory..."
Remove-Item -Recurse "${rawFilesPath}\release\temp"
Write-Host "Removed temp directory.`n"

# Output path for the release file generated
Write-Host "iw4x-rawfiles release script finished. File generated: ${rawFilesPath}\release\release.zip"
