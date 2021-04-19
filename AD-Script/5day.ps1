#загружаем модуль для работы с AD
Import-Module activedirectory
 
#задаем переменную
$days = (Get-Date).adddays(-40)

#Загружаем данные в файл в который попадут фамилии пользоватей чьи уз включены, и пароль менялся более 45 дней.
Get-ADUser -SearchBase ‘OU=UN,OU=UNS,DC=reg,DC=new,DC=test, DC=ru’ -filter {Enabled -eq "True" -and (passwordlastset -le $days)} -properties * | Select-Object Name > D:\PasswordExpired.txt