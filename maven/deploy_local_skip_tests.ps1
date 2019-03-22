# Локальная сборка проекта (без запуска тестов) без обновления версии, взаимодействия с scv и т.д.
# Скрипт запускать из корневой директории проекта

$appProjectRootPath = "./app"
$appFileName = "bet-strict.exe"

try{
	./deploy/download_dependencies.ps1
} catch {
	Write-Warning ""
	Write-Warning "[WARN]: DOWNLOAD DEPENDENCIES ERROR"
	Write-Warning "[WARN]: $($_.Exception)"
	Write-Warning ""
}

try{
	./deploy/compile.ps1
	./deploy/build.ps1
} catch {
	Write-Error ""
	Write-Error "[ERROR]: BUILD ERROR"
	Write-Error "[ERROR]: $($_.Exception)"
	Write-Error ""
	exit 1
}

try{
	./deploy/release.ps1 -appProjectRootPath "${appProjectRootPath}" -appFileName "${appFileName}"
} catch {
	Write-Error ""
	Write-Error "[ERROR]: RELEASE ERROR"
	Write-Error "[ERROR]: $($_.Exception)"
	Write-Error ""
	exit 1
}
