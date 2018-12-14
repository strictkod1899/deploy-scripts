# Локальная сборка проекта без обновления версии, взаимодействия с scv и т.д.
# Скрипт запускать из корневой директории проекта

$app_project_root_path = "./app"
$appFileName = "myapp.jar"

try{
	mvn dependency:copy-dependencies
} catch {
	Write-Error ""
	Write-Error "[ERROR]: DOWNLOAD DEPENDENCIES ERROR"
	Write-Error "[ERROR]: $($_.Exception)"
	Write-Error ""
	exit 1
}

try{
	./deploy/test.ps1
} catch {
	Write-Error ""
	Write-Error "[ERROR]: TESTS ERROR"
	Write-Error "[ERROR]: $($_.Exception)"
	Write-Error ""
	exit 1
}

try{
	./deploy/build.ps1
} catch {
	Write-Error ""
	Write-Error "[ERROR]: BUILD ERROR"
	Write-Error "[ERROR]: $($_.Exception)"
	Write-Error ""
	exit 1
}

try{
	./deploy/release.ps1 -appProjectRootPath $app_project_root_path -appFileName $appFileName
} catch {
	Write-Error ""
	Write-Error "[ERROR]: RELEASE ERROR"
	Write-Error "[ERROR]: $($_.Exception)"
	Write-Error ""
	exit 1
}
