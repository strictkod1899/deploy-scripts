# Полный deploy проекта с обновлением версии и выполнением push в ветку master
# Скрипт запускать из корневой директории проекта

./deploy/deploy.ps1 -mode "prod" -branch "master" -appFilePath ".\app\target\myapp.jar"
