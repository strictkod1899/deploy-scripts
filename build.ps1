# Выполнение сборки проекта без запуска тестов
# Скрипт запускать из корневой директории проекта

Write-Host ""
Write-Host "            - THE PROJECT BUILD HAS STARTED"
Write-Host ""

try{
    mvn install -DskipTests
}catch{
    throw "$($_.Exception)"
}

Write-Host ""
Write-Host "            - THE PROJECT BUILD HAS COMPLETED"
Write-Host ""
