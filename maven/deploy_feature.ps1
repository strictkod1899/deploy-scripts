# Полный deploy проекта с обновлением версии и выполнением push в ветку feature/xxx
# Скрипт запускать из корневой директории проекта

./deploy/deploy.ps1 -mode "feature" -branch "feature/xxx" -appFilePath ".\app\target\myapp.jar"
