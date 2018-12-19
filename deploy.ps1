# Выполнение полного развертывания проекта
# Скрипт запускать из корневой директории проекта

param(
	# required
	[string]$branch
)

$app_project_root_path = "./app"
$appFileName = "myapp.jar"
# modules without root pom.xml
$childModulesPath = "./db/pom.xml", "./services/pom.xml", "./app/pom.xml", "./jstrict/pom.xml"
$modulesPath = "./pom.xml", "./db/pom.xml", "./services/pom.xml", "./app/pom.xml"

if($branch -eq $null -Or $branch -eq ''){
	Write-Error ""
	Write-Error "[ERROR]: DEPLOY ERROR"
	Write-Error "[ERROR]: Branch for deploy is NULL"
	Write-Error ""
	exit 1
}

try{
	./deploy/download_dependencies.ps1
} catch {
	Write-Warning ""
	Write-Warning "[WARN]: DOWNLOAD DEPENDENCIES ERROR"
	Write-Warning "[WARN]: $($_.Exception)"
	Write-Warning ""
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
	# Update versions
	./deploy/update_versions_maven.ps1 -modulesPath $modulesPath
	
	# Update parent versions
	./deploy/update_parent_version_maven.ps1 -modulesPath $childModulesPath

	# Update dependency versions
	./deploy/update_dependency_version_maven -dependencyGroupId "ru.strict" -dependencyArtifactId "db" -modulesPath $modulesPath
	./deploy/update_dependency_version_maven -dependencyGroupId "ru.strict" -dependencyArtifactId "services" -modulesPath $modulesPath
} catch {
	Write-Error ""
	Write-Error "[ERROR]: UPDATE VERSION ERROR"
	Write-Error "[ERROR]: $($_.Exception)"
	Write-Error ""
	exit 1
}

try{
	./deploy/git_commit.ps1 -branch $branch -message "updated a version"
} catch {
	Write-Error ""
	Write-Error "[ERROR]: GIT COMMIT ERROR"
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
