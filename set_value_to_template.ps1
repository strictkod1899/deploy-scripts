# Заменить шаблон (переменную) на конкретное значение в указанном файле
# Шаблонное значение обозначается конструкцией ##{myname}##
# Скрипт запускать из корневой директории проекта
# Пример использования скрипта:
#    | ./deploy/set_value_to_template.ps1 -filePath "./sources/myfile.properties" -templateName "myname" -value "John"

param(
    # required
    [string]$filePath,
    # required
    # Наименование временной переменной без спец.символов [ ##{ ] и [ }## ]
    [string]$templateName,
    # required
    # Значение, устанавливаемое вместо шаблонной переменной
    [string]$value,
    # optional
    # Кодировка записи в файл. Необходимо передать значение, согласно параметру -Encoding команды Out-File
    # default = UTF8
    [string]$encoding
)

if($filePath -eq $null -Or $filePath -eq ''){
    throw "filePath is null"
}
if($templateName -eq $null -Or $templateName -eq ''){
    throw "templateName is null"
}
if($encoding -eq $null -Or $encoding -eq ''){
    Write-Warning "[WARN]: param 'encoding' is NULL, so will be using a default value"
    $encoding = "UTF8"
}

Write-Host ""
Write-Host "            - THE PROCESS OF SETTING TEMPLATE VALUE [${templateName}] IN FILE [${filePath}] HAS STARTED"
Write-Host ""

Write-Host "[INFO]: filePath = ${filePath}"
Write-Host "[INFO]: templateName = ${templateName}"
Write-Host "[INFO]: value = ${value}"
Write-Host "[INFO]: encoding = ${encoding}"

try{
	(Get-Content $filePath) |
	Foreach-Object {$_ -replace "##{${templateName}}##","${value}"}  |
	Out-File -FilePath "$filePath" -Encoding $encoding
}catch{
    throw "$($_.Exception)"
}

Write-Host ""
Write-Host "            - THE PROCESS OF SETTING TEMPLATE VALUE [${templateName}] IN FILE [${filePath}] HAS COMPLETED"
Write-Host ""
