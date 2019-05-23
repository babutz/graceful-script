#Saves the user password to run the application. Insecure!
$credentials = Get-Credential %USER_NAME%
$key = @(1..24)
$credentials.Password | ConvertFrom-SecureString -Key $key | Set-Content PASS_KEY.txt
