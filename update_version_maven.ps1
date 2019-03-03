# Обновить версию проекта в pom.xml файле.
# В зависимости от параметра 'isIncrement' версия будет либо увеличена на +1, либо уменьшина на -1
# Скрипт запускать из корневой директории проекта
# Пример использования скрипта:
#    | ./deploy/update_version_maven.ps1 -xmlFilePath "./app/pom.xml" -isIncrement 1

param(
    # required
    # example: ./app/pom.xml
    [string]$xmlFilePath,
    # optional
    # Увеличивать версию или уменьшать
    # 0 - null; 1 - increment; 2 - decrement
    # default = 1
    [int]$isIncrement,
    # optional
    # Структура файла для поиска тега version
    # default = "/ns:project/ns:version"
    [string]$xmlNodePath
)

if($xmlFilePath -eq $null -Or $xmlFilePath -eq ''){
	throw "xml filePath for update maven version is NULL"
}

if(!(Test-Path -Path "${xmlFilePath}")){
    throw "file not found [${xmlFilePath}]"
}

if($xmlNodePath -eq $null -Or $xmlNodePath -eq ''){
    Write-Warning "[WARN]: param 'xmlNodePath' is NULL, so will be using a default value"
    $xmlNodePath = "/ns:project/ns:version"
}

Write-Host ""
Write-Host "            - VERSION UPDATE FOR FILE '${xmlFilePath}' HAS STARTED"
Write-Host ""

Write-Host "[INFO]: xmlNodePath = '${xmlNodePath}'"

try{
    [xml]$xmlContent = Get-Content $xmlFilePath
    $namespaceManager = New-Object Xml.XmlNamespaceManager($xmlContent.NameTable)
    $namespace = $xmlContent.DocumentElement.NamespaceURI
    Write-Host "[INFO]: obtaned a namespace '${namespace}' from xml-file '${xmlFilePath}'"
    $namespaceManager.AddNamespace('ns', $namespace)
    $element = $xmlContent.SelectSingleNode("${xmlNodePath}", $namespaceManager)

    if($element -eq $null){
        throw "not found element '${xmlNodePath}' into file '${xmlFilePath}'"
    }

    [string]$versionValue = $element.InnerText
    Write-Host "[INFO]: current version = ${versionValue}"

    if($versionValue -eq $null -Or $versionValue -eq ''){
        throw "current version from file '${xmlFilePath}' is NULL"
    }

    $newVersionValue = &"./deploy/update_version.ps1" -version $versionValue -isIncrement $isIncrement | Select-Object -Last 1
    Write-Host "[INFO]: new version = ${newVersionValue}"
    $element.InnerText = "${newVersionValue}"
    $xmlContent.Save($xmlFilePath)
    Write-Host "[INFO]: new version had saved to xml-file '${xmlFilePath}'"
    Write-Host ""
    Write-Host "            - VERSION UPDATE FOR FILE '${xmlFilePath}' HAS COMPLETED"
    Write-Host ""
}catch{
    throw "$($_.Exception)"
}