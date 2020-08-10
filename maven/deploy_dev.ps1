# Полный deploy проекта с обновлением версии и выполнением push в ветку develop
# Скрипт запускать из корневой директории проекта

./deploy/deploy.ps1 -mode "dev" -branch "develop" -appFilePath ".\app\target\myapp.jar"
