# Полный deploy проекта с обновлением версии и выполнением push в указанную ветку
# Скрипт запускать из корневой директории проекта
# Пример использования скрипта:
#    | ./deploy/deploy.ps1 -mode "dev" -branch "develop" -appFilePath "./app/target/myapp.jar"

param(
	# required
	# Путь до файла, полученного в результате успешной сборки (используется для проверки)
	[string] $appFilePath,
	# optional
	# Режим: prod, dev, feature
	[string] $mode,
	# optional
	# git-ветка, в которую будет произведен push
	[string] $branch,
	# optional
	# Пропустить взаимодействие с git
	[Boolean] $skipGit,
	# optional
	# Пропустить тестирование проекта
	[Boolean] $skipTests,
	# optional
	# Пропустить обновление версии
	[Boolean] $skipUpdateVersion
)

# constants
$PROD_MODE = "prod"
$DEV_MODE = "dev"
$FEATURE_MODE = "feature"

$VERSIONS_FILE = "./deploy/versions.properties"

# custom fields
$submodules = "./db/pom.xml", "./services/pom.xml", "./app/pom.xml"
$modules = "./pom.xml", "./db/pom.xml", "./services/pom.xml", "./app/pom.xml"

# declare
$prevVersion
$newVersion

if ($appFilePath -eq $null -Or $appFilePath -eq '') {
	Write-Error "[ERROR]: DEPLOY ERROR - appFilePath for deployment is NULL"
	exit 1
}

if ($skipGit -eq $null) {
	$skipGit = $False
}

if ($skipTests -eq $null) {
	$skipTests = $False
}


if ($skipUpdateVersion -eq $null) {
	$skipUpdateVersion = $False
}

if ($mode -cne $null -And $mode -cne '') {
	if ($mode -cne $PROD_MODE -And $mode -cne $DEV_MODE -And $mode -cne $FEATURE_MODE) {
		Write-Error "[ERROR]: DEPLOY ERROR - Unsupported mode [$mode]"
		exit 1
	}
}

try {
	./deploy/core/download_dependencies.ps1
} catch {
	Write-Warning ""
	Write-Warning "[WARN]: DOWNLOAD DEPENDENCIES ERROR"
	Write-Warning "[WARN]: $($_.Exception)"
	Write-Warning ""
}

if ($skipTests -eq $True) {
	Write-Warning ""
	Write-Warning "[WARN]: PROJECT BUILD WITHOUT TEST"
	Write-Warning ""

	./deploy/core/build_skip_tests.ps1
} else {
	./deploy/core/build.ps1
}

if (!(Test-Path -Path "${appFilePath}")) {
	Write-Error "[ERROR]: BUILD ERROR - app file not found [${appFilePath}]"
	exit 1
}

if ($skipUpdateVersion -eq $True) {
	Write-Warning ""
	Write-Warning "[WARN]: PROJECT BUILD WITHOUT UPDATE VERSION"
	Write-Warning ""
} else {
	
	if ($mode -eq $null -Or $mode -eq '') {
		Write-Error "[ERROR]: DEPLOY ERROR - mode for update version is NULL"
		exit 1
	}

	# create new newVersion
	try {
		$prevModeVersion = &"./deploy/other/read_from_properties.ps1" -filePath $VERSIONS_FILE -itemName $mode | Select-Object -Last 1
		$newModeVersion = &"./deploy/version/increment_version.ps1" -version $prevModeVersion | Select-Object -Last 1
		./deploy/other/set_properties_value.ps1 -filePath $VERSIONS_FILE -itemName $mode -value $newModeVersion

		if ($mode -eq $PROD_MODE) {
			$prodVersion = &"./deploy/other/read_from_properties.ps1" -filePath $VERSIONS_FILE -itemName $PROD_MODE | Select-Object -Last 1
			
			$newVersion = $prodVersion
		} elseif ($mode -eq $DEV_MODE) {
			$prodVersion = &"./deploy/other/read_from_properties.ps1" -filePath $VERSIONS_FILE -itemName $PROD_MODE | Select-Object -Last 1
			$devVersion = &"./deploy/other/read_from_properties.ps1" -filePath $VERSIONS_FILE -itemName $DEV_MODE | Select-Object -Last 1

			$newVersion = "$prodVersion-SNAPSHOT-$devVersion"
		} elseif ($mode -eq $FEATURE_MODE) {
			$prodVersion = &"./deploy/other/read_from_properties.ps1" -filePath $VERSIONS_FILE -itemName $PROD_MODE | Select-Object -Last 1
			$featureVersion = &"./deploy/other/read_from_properties.ps1" -filePath $VERSIONS_FILE -itemName $FEATURE_MODE | Select-Object -Last 1

			$newVersion = "$prodVersion-FEATURE-$featureVersion"
		}
	} catch {
		Write-Error "[ERROR]: CREATE NEW VERSION ERROR - $($_.Exception)"
		exit 1
	}

	# update versions
	try {
		foreach($module in $modules) {
			./deploy/version/maven_set_version.ps1 -filePath $module -newVersion $newVersion

			./deploy/version/maven_set_dependency_version.ps1 -groupId "ru.strict.bet" -artifactId "db" -filePath $module -newVersion $newVersion
			./deploy/version/maven_set_dependency_version.ps1 -groupId "ru.strict.bet" -artifactId "services" -filePath $module -newVersion $newVersion
			./deploy/version/maven_set_dependency_version.ps1 -groupId "ru.strict.bet" -artifactId "app" -filePath $module -newVersion $newVersion
		}

		foreach($module in $submodules) {
			./deploy/version/maven_set_parent_version.ps1 -filePath $module -newVersion $newVersion
		}
	} catch {
		Write-Error "[ERROR]: UPDATE VERSIONS ERROR - $($_.Exception)"
		exit 1
	}
}

try {
	if ($skipGit -eq $True) {
		Write-Warning ""
		Write-Warning "[WARN]: GIT SKIP"
		Write-Warning ""
	} else {
		./deploy/git/git_commit.ps1 -branch "${branch}" -message "version updated"

		if ($mode -eq $PROD_MODE) {
			git tag $newVersion
			git push origin $newVersion
		}
	}
} catch {
	Write-Error "[ERROR]: GIT COMMIT ERROR - $($_.Exception)"
	exit 1
}

try {
	./deploy/core/install.ps1
} catch {
	Write-Error "[ERROR]: INSTALL ERROR - $($_.Exception)"
	exit 1
}

if (!(Test-Path -Path "${appFilePath}")) {
	Write-Error "[ERROR]: INSTALL ERROR - app file not found [${appFilePath}]"
	exit 1
}

try {
	#./deploy/release.ps1
} catch {
	Write-Error "[ERROR]: RELEASE ERROR - $($_.Exception)"
	exit 1
}