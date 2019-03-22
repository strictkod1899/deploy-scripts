# Скачивание зависимостей проекта
# Скрипт запускать из корневой директории проекта

Write-Host ""
Write-Host "            - THE DEPENDENCIES DOWLOADING HAS STARTED"
Write-Host ""

try{
    mvn dependency:copy-dependencies
}catch{
    throw "$($_.Exception)"
}

Write-Host ""
Write-Host "            - THE DEPENDENCIES DOWLOADING HAS COMPLETED"
Write-Host ""
