# Обновить версии блока parent указанных проектов в pom.xml файле.
# В зависимости от параметра 'isIncrement' версия будет либо увеличена на +1, либо уменьшина на -1
# Скрипт запускать из корневой директории проекта
# Пример использования скрипта:
#    | $childModulesPath = "./db/pom.xml", "./services/pom.xml", "./app/pom.xml", "./jstrict/pom.xml"
#    | ./deploy/update_parent_version_maven.ps1 -modulesPath $childModulesPath

param(
    # required
    # Список модулей, в которых изменится версия родительского модуля
    # example: ./app/pom.xml, ./db/pom.xml
    [string[]]$modulesPath,
    # optional
    # Увеличивать версию или уменьшать
    # 0 - null; 1 - increment; 2 - decrement
    # default = 1
    [int]$isIncrement
)

if($modulesPath -eq $null -Or $modulesPath.length -lt 1){
	throw "param 'modulesPath' is NULL"
}

foreach($modulePath in $modulesPath){
    if(!(Test-Path -Path "${modulePath}")){
        throw "file not found [${modulePath}] from param 'modulesPath'"
    }
}

Write-Host ""
Write-Host "            - THE PARENT VERSION UPDATE HAS STARTED"
Write-Host ""

try{
    foreach($modulePath in $modulesPath){
        ./deploy/update_version_maven.ps1 -xmlFilePath $modulePath -isIncrement $isIncrement -xmlNodePath "/ns:project/ns:parent/ns:version"
        
        Write-Host ""
        Write-Host "[INFO]:         - parent version update for file '$modulePath' has completed"
        Write-Host ""
    }
    Write-Host ""
    Write-Host "            - THE PARENT VERSION UPDATE HAS COMPLETED"
    Write-Host ""
}catch{
    throw "$($_.Exception)"
}