# Выполнение сборку проекта и установку в локальный репозиторий (без запуска тестов)
# Скрипт запускать из корневой директории проекта

Write-Host ""
Write-Host "            - [START] - PROJECT INSTALL"
Write-Host ""

mvn clean install -DskipTests

Write-Host ""
Write-Host "            - [FINISH] - PROJECT INSTALL"
Write-Host ""