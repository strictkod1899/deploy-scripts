# Commit всех изменений с использованием указанной ветки и push в репозиторий
# При использовании скрипта необходимо использовать, либо параметры $branch и $message, либо все указанные параметры
# Скрипт запускать из корневой директории проекта
# Пример использования скрипта:
#    | ./deploy/git_commit.ps1 -branch "${branch}" -message "updated a version"

param(
    # required
    # Наименование git-ветки для коммита
    [string]$branch,
    # optional
    # Сообщение коммита
    # default = 'update files'
    [string]$message,
    # optional
    # Имя пользователя git-репозитория
    [string]$username,
    # optional
    # Git-провайдер
    # example: github.com
    [string]$gitProvider,
    # optional
    # Наименование git-репозитория
    # example: myrepository
    [string]$repositoryName
)

if($branch -eq $null -Or $branch -eq ''){
    throw "branch is null"
}

if($message -eq $null -Or $message -eq ''){
    Write-Warning "[WARN]: param 'message' is NULL. Default value will be using"
    $message = 'update files'
}

Write-Host ""
Write-Host "            - THE GIT COMMIT TO BRANCH [${branch}] HAS STARTED"
Write-Host ""

Write-Host "[INFO]: message = ${message}"
Write-Host "[INFO]: username = ${username}"
Write-Host "[INFO]: gitProvider = ${gitProvider}"
Write-Host "[INFO]: repositoryName = ${repositoryName}"
try{
    Write-Host "[INFO]: checkout to branch [${branch}] has started"
    git checkout $branch
    $currentBranch = git rev-parse --abbrev-ref HEAD
    if($currentBranch -ne $branch){
        throw "branch checkout error"
    }

    git add *
    
    git commit -m \"$message\"
    if($username -eq $null -Or $username -eq '' -Or $gitProvider -eq $null -Or $gitProvider -eq '' -Or $repositoryName -eq $null -Or $repositoryName -eq ''){
        Write-Host "[INFO]: push to origin has started"
        git push origin $branch
    } else {
        Write-Host "[INFO]: push to repository [${repositoryName}] by user [${username}] has started"
        git push git@${gitProvider}:${username}/${repositoryName}.git $branch
    }

    Write-Host ""
    Write-Host "            - THE GIT COMMIT TO BRANCH [${branch}] HAS COMPLETED"
    Write-Host ""
}catch{
    throw "$($_.Exception)"
}