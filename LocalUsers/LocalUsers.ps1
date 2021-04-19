#Поиск локальных пользователей и групп на компьютерах

Import-Module ActiveDirectory -ErrorAction SilentlyContinue
#write-host "Выполнение скрипта PowerShell запущено" -ForegroundColor Green

$Header = @"
<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #CEE3F6;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
h1 {font-size:200%;text-align:center }
h2 {font-size:120%;text-align:center }
h3 {font-size:100%;text-align:left }
</style>
"@

function resultFragment
    {
    param($computername)
        $resultTMP = $null;
        [ADSI]$ComputerManage = "WinNT://$computername"
        $resultTMP += $ComputerManage.children|where({$_.class -eq 'user'}) |
        Select @{Name="Контейнер в ЕСК";Expression={$computerDistinguishedName}},
        @{Name="Компьютер";Expression={$_.Parent.split("/")[-1]}},  
        @{Name="Описание компьютера";Expression={$ComputerDescriptionESK}}, 
        @{Name="Состояние в ЕСК";Expression={$computerEnabledESK}},   
        @{Name="Ping";Expression={$ComputerPing}}, 
        @{Name="Локал.пользователи и группы";Expression={"User"}},
        @{Name="Имя локал.пользователя или группы";Expression={$_.name.value}},
        @{Name="Описание локал.пользователя или группы";Expression={$_.description}}, 
        @{name="Состояние";Expression={$ADS_UF_ACCOUNTDISABLE=0x0002; if ($_.psbase.properties.item("userflags").value -band $ADS_UF_ACCOUNTDISABLE) {"Отключено"} else {"Включено"}}},
        @{Name="Членство в группах/ Члены группы";Expression={
        $groups = $_.Groups() 
        ($groups | Foreach-Object {
            $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)
        }) -join ';<br>'
        }},
        @{Name="Примечания";Expression={""}};

        $resultTMP += $ComputerManage.children|where({$_.class -eq 'group'}) |
        Select @{Name="Контейнер в ЕСК";Expression={$computerDistinguishedName}},
        @{Name="Компьютер";Expression={$_.Parent.split("/")[-1]}},  
        @{Name="Описание компьютера";Expression={$ComputerDescriptionESK}}, 
        @{Name="Состояние в ЕСК";Expression={$computerEnabledESK}},   
        @{Name="Ping";Expression={$ComputerPing}}, 
        @{Name="Локал.пользователи и группы";Expression={"Group"}},
        @{Name="Имя локал.пользователя или группы";Expression={$_.name.value}},
        @{Name="Описание локал.пользователя или группы";Expression={$_.description}},
        @{Name="Состояние";Expression={"-"}},
        @{Name="Членство в группах/ Члены группы";Expression={
        [ADSI]$group = "$($_.Parent)/$($_.Name),group"
        $members = $Group.psbase.Invoke("Members")
        ($members | ForEach-Object {
            $_.GetType().InvokeMember("Name",'GetProperty',$null,$_,$null)
        }) -join ';<br>' 
        }},
        @{Name="Примечания";Expression={""}};  
    return  $resultTMP;    
}

function tempHTML{
    param()
    ConvertTo-HTML -head $Header -PreContent "<h1>ОТЧЕТ «Локальные пользователи и группы на компьютерах ($settingsFileValuesCodeOrganization)»</h1>" > $filename    
    $envUser = $(try {(Get-ADUser -Identity $env:UserName -Properties displayname).displayname} catch{  $null  })      
    $messagebody = "Дата               : $date`r`n<br>" + "Пользователь       : $env:UserName ($envUser)`r`n<br>" + "Выполнено c        : $env:ComputerName`r`n<br>" + "Поиск в            : $settingsFileValuesSearchBase`r`n<br>" + "Поиск (Исключения) : $settingsFileValuesException_Add`r`n<br>"
    (ConvertTo-HTML -head $Header -PreContent "<h2>$messagebody</h2>") -replace "&lt;br&gt;", '<br>' >> $filename    
};

$date = Get-Date -Format "yyyy.MM.dd HH:mm:ss";

$settingsFile = "\\"+$env:ComputerName+"\C$\PowerShell\Settings.txt";
$settingsFileValues = (Get-Content $settingsFile) -replace " : ","=" | ConvertFrom-StringData;
$settingsFileValuesCodeOrganization =  $settingsFileValues[0].CodeOrganization;
$settingsFileValuesSearchBase =  $settingsFileValues[1].SearchBase;
$settingsFileValuesException =  $settingsFileValues[2].SearchBase;
if($settingsFileValuesException -ne ""){
    $settingsFileValuesException_Add = $settingsFileValues[2].Exception
} 
[Array]$settingsFileValuesException = $settingsFileValuesException_Add.split(";");

if($settingsFileValues[3].Email_To -ne ""){
    $settingsFileValuesEmail_To_Add = $settingsFileValues[3].Email_To + ",user@mail.domain"
} 
else {$settingsFileValuesEmail_To_Add = "user@mail.domain"}
[Array]$settingsFileValuesEmail_To = $settingsFileValuesEmail_To_Add.split(",");

#$settingsFileValuesEmail_From = $settingsFileValues[4].Email_From;
#$settingsFileValuesEmail_SMTPServer = $settingsFileValues[5].Email_SMTPServer;
$computersArray = Get-ADComputer -Filter * -SearchBase $settingsFileValuesSearchBase -Properties Name, canonicalName, distinguishedName  | sort canonicalName;

ForEach ($Exception in $settingsFileValuesException){
    $Exception = "*"+$Exception+"*"
    $computersArray = @($computersArray | Where-Object {$_.canonicalName -notlike $Exception })
}

$filename = "\\"+$env:ComputerName+"\C$\PowerShell\LocalAdminUsersGroups_" + $settingsFileValuesCodeOrganization + ".html";
$computersArrayCount = $computersArray.count;

$messagebody = $null;
tempHTML;

[int]$index = 0;
$result = $null;

ForEach ($computerInComputersArray in $computersArray)
{
    $index += 1;
    $computer = Get-ADComputer -Identity $computerInComputersArray -Properties name, description, canonicalName, distinguishedName, Enabled;   
    $computerName = $Computer.Name  
    $ComputerDescriptionESK = $Computer.description;
    $computerDistinguishedName = $computer.distinguishedName.Split(",")[1].Replace("OU=","");
    tempHTML;
    $messagebody += $index.ToString() + "/" + $computersArrayCount + ") " + $Computer.canonicalName + "`r`n<br>";
    (ConvertTo-HTML -head $Header -PreContent "<h3>$messagebody</h3>") -replace '&lt;br&gt;', '<br>' >> $filename 
    #write-host $index"/"$computersArrayCount") " $ComputerdistinguishedName "/" $Computer.name  -ForegroundColor Green
    $computerEnabledESK = $computer.enabled;
    if($computerEnabledESK -eq $true) {$computerEnabledESK = "Включено "} else {$computerEnabledESK = "Отключено"};
    $computerPing = $(try {Test-Connection -Source $env:ComputerName -ComputerName $computer.name -Count 1 -ErrorAction SilentlyContinue} catch{$_.Exception.message})
    if($computerPing -ne $null) {$computerPing = "Да"} else {$ComputerPing = "Нет"};
  
    
    $resultFragment = resultFragment -computerName $computerName;
    $tryAccess = $null;
    if($resultFragment -eq $null)
    {
        if($computerPing -eq "Нет")
        {
            $properties = [ordered]@{
            'Контейнер в ЕСК'= $computerDistinguishedName;`
            'Компьютер'= $computer.name;`
            'Описание компьютера'= $ComputerDescriptionESK;`
            'Состояние в ЕСК'= $computerEnabledESK;`
            'Ping'= $ComputerPing;`
            'Локал.пользователи и группы'= "-";
            'Имя локал.пользователя или группы'= "-";`
            'Описание локал.пользователя или группы'= "-";`
            'Состояние'= "-";`
            'Членство в группах/ Члены группы'= "-";`
            'Примечание'= "";   
            }#properties   
               
        }
        else
        {
            $properties = [ordered]@{
            'Контейнер в ЕСК'= $computerDistinguishedName;`
            'Компьютер'= $computer.name;`
            'Описание компьютера'= $ComputerDescriptionESK;`
            'Состояние в ЕСК'= $computerEnabledESK;`
            'Ping'= $ComputerPing;`
            'Локал.пользователи и группы'= "ERROR: Отказано в доступе/ RPC недоступен";
            'Имя локал.пользователя или группы'= "ERROR: Отказано в доступе/ RPC недоступен";`
            'Описание локал.пользователя или группы'= "ERROR: Отказано в доступе/ RPC недоступен";`
            'Состояние'= "ERROR: Отказано в доступе/ RPC недоступен";`
            'Членство в группах/ Члены группы'= "ERROR: Отказано в доступе/ RPC недоступен";`
            'Примечание'= "";        
            }#properties  
        }   
        $resultFragment += New-Object -TypeName PSObject -Property $properties        
    }
    [psobject[]]$result += $resultFragment;
    [psobject[]]$result += "";
}

ConvertTo-HTML -head $Header -PreContent "<h1>ОТЧЕТ «Локальные пользователи и группы на компьютерах ($settingsFileValuesCodeOrganization)»</h1>" > $filename
$messagebody = $null;
$envUser = $(try {(Get-ADUser -Identity $env:UserName -Properties displayname).displayname} catch{  $null  })      
$messagebody = "Дата               : $date`r`n<br>" + "Пользователь       : $env:UserName ($envUser)`r`n<br>" + "Выполнено c        : $env:ComputerName`r`n<br>" + "Поиск в            : $settingsFileValuesSearchBase`r`n<br>" + "Поиск (Исключения) : $settingsFileValuesException_Add`r`n<br>"
(ConvertTo-HTML -head $Header -PreContent "<h2>$messagebody</h2>") -replace '&lt;br&gt;', '<br>' >> $filename

(((((($result | ConvertTo-Html -Head $Header) -replace "<td>Нет</td>", "<td style='background-color:red'>Нет</td>") -replace "<td>User</td>", "<td style='background-color:#dbdbdb'>User</td>") -replace '&lt;br&gt;', '<br>') -replace "<td>Включено</td>", "<td style='background-color:green'>Включено</td>") -replace "<td>Отключено</td>", "<td style='background-color:red'>Отключено</td>") -replace "<td>ERROR: Отказано в доступе/ RPC недоступен</td>", "<td style='background-color:red'>ERROR: Отказано в доступе/ RPC недоступен</td>" >> $filename

$messagebody = ($messagebody) -replace '<br>', ''
Write-Verbose "Sending e-mail"
$params = @{'To'= $settingsFileValuesEmail_To
            'From'= 'mail@mail.ru'
            'Subject'= '[auto] ОТЧЕТ «Локальные пользователи и группы на компьютерах (' + $settingsFileValuesCodeOrganization + ')» ' + $date
            'Body'= $messagebody
            'Attachments'= $filename
            'SMTPServer'= '10.102.188.20'}
$encoding = [System.Text.Encoding]::UTF8
Send-MailMessage @params -Encoding $encoding

#write-host "Файл отправлен на почту" -ForegroundColor Green