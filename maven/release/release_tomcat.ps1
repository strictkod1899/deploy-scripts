# Выполнение публикации собранного проекта: развертывание на сервере tomcat
# Скрипт запускать из корневой директории проекта
# Пример использования скрипта:
#    | ./deploy/release_tomcat.ps1 -tomcatPath "A:\\Program Files/Java/servers/apache-tomcat-9.0.6" -appFilePath "./deploy/target/myapp.war"

param(
	#required
	# Путь до каталога tomcat
	# example: C:\\tomcat
	[string]$tomcatPath,
	# required
	# example: ./deploy/target/myapp.war
	[string]$appFilePath,
	# optional
	# Конечное наименование приложения при копировании в каталог tomcat.
	# Указывать без расширения файла. Предполагается, что используется war-файл
	# default = ROOT
	[string]$targetAppName
)

Write-Host ""
Write-Host "			- THE PROJECT TOMCAT RELEASE HAS STARTED"
Write-Host ""

if($tomcatPath -eq $null -Or $tomcatPath -eq ''){
	throw "param 'tomcatPath' IS NULL"
}
if($appFilePath -eq $null -Or $appFilePath -eq ''){
	throw "param 'appFilePath' IS NULL"
}
if($targetAppName -eq $null -Or $targetAppName -eq ''){
    Write-Warning "[WARN]: param 'targetAppName' is NULL, so will be using a default value"
	$targetAppName = "ROOT"
}

Write-Host ""
Write-Host "[INFO]:			- determine variables"
Write-Host ""

try{
	$tomcatBin = "${tomcatPath}/bin"
	$tomcatWebApps = "${tomcatPath}/webapps"
	$appExtension = "war"
	$targetAppFolder = "${tomcatWebApps}/${targetAppName}"
	$targetAppPath = "${tomcatWebApps}/${targetAppName}.${appExtension}"

	Write-Host "[INFO]: - tomcatPath = ${tomcatPath}"
	Write-Host "[INFO]: - tomcatBin = ${tomcatBin}"
	Write-Host "[INFO]: - tomcatWebApps = ${tomcatWebApps}"
	Write-Host "[INFO]: - appFilePath = ${appFilePath}"
	Write-Host "[INFO]: - targetAppName = ${targetAppName}"
	Write-Host "[INFO]: - appExtension = ${appExtension}"

	Write-Host ""
	Write-Host "[INFO]:			- stop server has started"
	Write-Host ""

	try{
		&"${tomcatBin}/shutdown"
		Start-Sleep -s 5
	}catch{
		throw "$($_.Exception)"
	}

	Write-Host ""
	Write-Host "[INFO]:			- tomcat webapp clean has started"
	Write-Host ""
	If(Test-Path -Path "${targetAppFolder}"){
		Remove-Item "${targetAppFolder}" -Recurse -ErrorAction Stop
	}
	If(Test-Path -Path "${targetAppPath}"){
		Remove-Item "${targetAppPath}" -ErrorAction Stop
	}

	Write-Host ""
	Write-Host "[INFO]:			- project copy in tomcat has started"
	Write-Host ""
	Copy-Item $appFilePath -Destination $targetAppPath -ErrorAction Stop

	Write-Host ""
	Write-Host "[INFO]:			- start server has started"
	Write-Host ""

	try{
		&"${tomcatBin}/startup"
		Start-Sleep -s 5
	}catch{
		throw "$($_.Exception)"
	}

	Write-Host ""
	Write-Host "			- THE PROJECT TOMCAT RELEASE HAS COMPLETED"
	Write-Host ""
}catch{
	throw "$($_.Exception)"
}
