# Сборка проекта (обновление версии и push в ветку git не выполняется)
# Скрипт запускать из корневой директории проекта

./deploy/deploy.ps1 -appFilePath ".\app\target\myapp.jar" -skipGit $True -skipUpdateVersion $True
