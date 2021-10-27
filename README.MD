# deploy-scripts
Репозиторий содержит скрипты для организации сборки java-приложения с использованием maven.

В процессе выполнения происходит инкрементное увеличение номера сборки в зависимости от запущенного режима:
- prod (ветка `master`)
- feature (ветка `feature/Xxx` или `bugfix/Xxx`)
- dev (ветка `develop` или `любая другая`)

Демонстрация версионирования:
![alt text](https://github.com/strictkod1899/deploy-scripts/blob/master/CI.jpg?raw=true)