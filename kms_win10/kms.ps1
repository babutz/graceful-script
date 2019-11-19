if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }
New-Item -Path `C:\KMS`  -ItemType 'Directory' -Force | Out-Null
Add-MpPreference -ExclusionPath "C:\KMS"
Add-MpPreference -ExclusionPath "C:\ProgramData\KMSAutoS"
Add-MpPreference -ExclusionPath "C:\ProgramData\KMSAutoS\bin"
Add-MpPreference -ExclusionPath "C:\ProgramData\KMSAutoS\*\*\"
Add-MpPreference -ExclusionPath "C:\ProgramData\KMSAuto"
Add-MpPreference -ExclusionPath "C:\ProgramData\KMSAuto\*\"
Add-MpPreference -ExclusionPath "C:\ProgramData\KMSAuto\*\*\"
Add-MpPreference -ExclusionPath "C:\Users\%UserName%\AppData\Local\Temp"
Add-MpPreference -ExclusionPath "C:\Users\%UserName%\AppData\Local\Temp\KMSAutoNet.tmp"
Add-MpPreference -ExclusionPath "C:\Windows\System32\Tasks\KMSAutoNet"
