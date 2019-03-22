# Выполнение компиляции проекта
# Скрипт запускать из корневой директории проекта

Write-Host ""
Write-Host "            - THE PROJECT COMPILE HAS STARTED"
Write-Host ""

try{
    mvn clean compile
}catch{
    throw "$($_.Exception)"
}

Write-Host ""
Write-Host "            - THE PROJECT COMPILE HAS COMPLETED"
Write-Host ""
