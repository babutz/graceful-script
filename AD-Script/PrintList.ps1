$Computers = Get-ADComputer -Filter {Name -like "i000-*"}

Foreach ($Computer in $Computers)
{
Get-Printer -ComputerName $Computer.Name | where {$_.PortName -Like "10.145.102.180"}|format-list ComputerName, Name, PortName | Out-File C:\PrintList.txt
}