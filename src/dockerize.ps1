Param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet('Build', 'Build-NoCache', 'Run', 'Run-Detached', 'Stop', 'Login', 'Tag', 'Push', 'Connect', 'Connect-Image')]
    [String]
    $Action,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [String]
    $Tag,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [String]
    $Service
)

Set-StrictMode -Version Latest

$script:App = 'GenericAppvrx'
$script:Service = $Service.Trim().ToLower() # (Get-Item -Path $PSScriptRoot).Name.ToLower();
$script:Image = "$($script:App)-$($script:Service)"
$script:Registry = 'crGenericAppvrxwestusdev'
$script:ServicePath = "./services/$($script:Service)"

if ((Test-Path -Path $script:ServicePath) -eq $false) {
    Write-Error "Service `"$($script:Service)`" was not found in `"./services`" folder"
    Exit 1;
}

switch ($Action) {
    'Build' {
        docker build `
            --file "$($script:ServicePath)/Dockerfile" `
            --tag "$($script:Image):$Tag" `
            --build-arg SERVICE=$($script:Service) `
            .
    }

    'Build-NoCache' {
        docker build `
            --no-cache `
            --file "$($script:ServicePath)/Dockerfile" `
            --tag "$($script:Image):$Tag" `
            --build-arg SERVICE=$($script:Service) `
            .
    }

    'Run-Detached' {
        docker run `
            --detach -it `
            --publish 80:3000 `
            --env-file "./$($script:ServicePath)/.env" `
            --name $script:Image `
            --rm `
            "$($script:Image):$Tag"
    }

    'Run' {
        docker run `
            -it `
            --publish 80:3000 `
            --env-file "./$($script:ServicePath)/.env" `
            --name $script:Image `
            --rm `
            "$($script:Image):$Tag"
    }

    'Stop' {
        docker stop `
            $script:Image
    }

    'Login' {
        az acr login --name $script:Registry
    }

    'Tag' {
        docker tag `
            "$($script:Image):$Tag" `
            "$($script:Registry).azurecr.io/$($script:Image):$Tag"
    }

    'Push' {
        docker push `
            "$($script:Registry).azurecr.io/$($script:Image):$Tag"
    }

    'Connect' {
        docker exec `
            -it `
            $script:Image `
            /bin/bash
    }

    'Connect-Image' {
        docker run `
            -it `
            --env-file "./$($script:ServicePath)/.env" `
            --name $script:Image `
            --rm `
            "$($script:Image):$Tag" `
            /bin/bash
    }
}
