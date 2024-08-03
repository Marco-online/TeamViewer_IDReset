#pragma compile(FileDescription, TeamViewer Reset ID)
#pragma compile(FileVersion, 1.0.0.1)
#pragma compile(ProductName, TeamViewer Reset ID)
#pragma compile(ProductVersion, 1.0.0.1)
#pragma compile(LegalCopyright, Copyright © 1990-2024)

#NoTrayIcon
#RequireAdmin

$File1 = @TempDir & "\Reset_ID.bat"
$File2 = @TempDir & "\CreateReset_ID.ps1"

FileCopy("Reset_ID.bat", $File1, 1) ;
FileCopy("CreateReset_ID.ps1", $File2, 1)

FileInstall("Reset_ID.bat", $File1)
FileInstall("CreateReset_ID.ps1", $File2)

Run(@ComSpec & ' /c "' & $File1 & '"', @TempDir, @SW_HIDE)

Sleep(10000)

Exit