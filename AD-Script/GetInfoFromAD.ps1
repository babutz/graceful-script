$objSearcher = New-Object System.DirectoryServices.DirectorySearcher
$objSearcher.SearchRoot = "LDAP://OU=XXX,OU=XXX,DC=XXX,DC=XXX,DC=XXX,DC=XXX"
#$ObjectSearcher.Filter = "(&(ObjectCategory=person)(objectClass=User))" 
$objSearcher.Filter = "(&(objectCategory=person)(!userAccountControl:1.2.840.113556.1.4.803:=2))"
$users = $objSearcher.FindAll()
# Количество учетных записей
$users.Count
$users | ForEach-Object {
   $user = $_.Properties
   New-Object PsObject -Property @{
   Должность = [string]$user.title
   Отдел = [string]$user.department
   #Логин = [string]$user.userprincipalname
   Телефон = [string]$user.telephonenumber
   Комната = [string]$user.physicaldeliveryofficename
   ФИО = [string]$user.cn
    }
} | Export-Csv -NoClobber -Encoding utf8 -Path  "P:\app\PowerShell\AD info\list_users2.csv" -Force