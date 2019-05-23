#Run the application from another user without entering a password. Insecure.
Wait-Event -Timeout 15

$key = @(1..24)
$user = "USER_NAME%"
$password = Get-Content key.txt|ConvertTo-SecureString -Key $key
$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $user, $password

 
Start-Process -FilePath 'D:\Soft\TNM\tnm.exe' -Credential $credentials 
Start-Process -FilePath 'C:\lotus\notes\notes.exe'
Start-Process -FilePath 'C:\Program Files (x86)\1cv8\common\1cestart.exe'
