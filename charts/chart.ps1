Param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet('Install', 'Uninstall', 'Upgrade', 'Tag', 'Push', 'Pull', 'Pack', 'Remove', 'Export', 'Login')]
    [String]
    $Action,

    [Parameter(Mandatory = $false)]
    [String]
    $Service,

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [String]
    $Tag,

    [Parameter(Mandatory = $false)]
    [ValidateSet($null, 'dev', 'prod')]
    [String]
    $Env,
    
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [String]
    $Folder,
    
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [ValidatePattern('^\d+.\d+.\d+$')]
    [String]
    $ChartVersion,
    
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [String]
    $AppVersion
)

Set-StrictMode -Version Latest

if ($Env -ne $null) {
    $Env = $Env.ToLower();
}

if ($Service -ne $null) {
    $script:Service = $Service.Trim().ToLower() # (Get-Item -Path $PSScriptRoot).Name.ToLower();
}

$script:App = 'GenericAppvrx'
$script:Image = "$($script:App)-$($script:Service)"
$script:Registry = 'crGenericAppvrxwestusdev'
$script:ServicePath = "./$($script:Image)"
$script:ChartFile = "$($script:ServicePath)/Chart.yaml"
$script:InitialChart = $null

function Confirm-Parameter {
    [CmdletBinding()]
    param( 
        [Parameter(Mandatory)]
        [String]
        $Name,

        [Parameter(Mandatory)]
        [AllowEmptyString()]        
        [String]
        $Value
    )
    process {
        if ([String]::IsNullOrEmpty($Value) -eq $true) {
            Write-Error "$Name parameter must be specified"
            Exit 1
        }
    }
}

function Confirm-Service {
    [CmdletBinding()]
    param()
    process {
        Confirm-Parameter -Name 'Service' -Value $Service

        if ((Test-Path -Path $script:ServicePath) -eq $false) {
            Write-Error "Service `"$($script:Service)`" was not found in `"./services`" folder"
            Exit 1;
        }
    }
}

function Read-Chart {    
    [CmdletBinding()]
    [OutputType([String])]
    param()
    process {
        return Get-Content -Path $script:ChartFile -Raw
    }
}

function Update-Chart {    
    [CmdletBinding()]
    [OutputType([String])]
    param( 
        [Parameter(Mandatory)]
        [String]
        $Chart
    )
    process {        
        Confirm-Parameter -Name 'AppVersion' -Value $AppVersion
        Confirm-Parameter -Name 'ChartVersion' -Value $ChartVersion

        $updatedChart = $Chart -replace 'version: (.*)', "version: $ChartVersion"
        $updatedChart = $updatedChart -replace 'appVersion: (.*)', "appVersion: $AppVersion"

        return $updatedChart
    }
}

function Save-Chart {    
    [CmdletBinding()]
    param( 
        [Parameter(Mandatory)]
        [String]
        $Chart
    )
    process {
        Set-Content -Path $script:ChartFile -Value $Chart
    }
}

function Set-Chart {
    [CmdletBinding()]
    [OutputType([String])]
    param()
    process {
        $chart = Read-Chart
        $updatedChart = Update-Chart -Chart $chart
        Save-Chart -Chart $updatedChart
        return $chart
    }
}

switch ($Action) { 
    'Login' {
        #az login
        az acr login --name $script:Registry
        az acr helm repo add --name $script:Registry
    }

    'Install' {
        Confirm-Service
        Confirm-Parameter -Name 'Env' -Value $Env

        $chart = Set-Chart

        try {
            helm install `
                $script:Image `
                $script:ServicePath `
                --values "$($script:ServicePath)/values/$Env-values.yaml" `
                --namespace $script:App
        } finally {           
            Save-Chart -Chart $chart
        }
    }

    'Uninstall' {
        Confirm-Service
        helm uninstall `
            $script:Image `
            --namespace $script:App
    }

    'Upgrade' {
        Confirm-Service
        Confirm-Parameter -Name 'Env' -Value $Env

        $chart = Set-Chart

        try {
            helm upgrade `
                $script:Image `
                $script:ServicePath `
                --install `
                --values "$($script:ServicePath)/values/$Env-values.yaml" `
                --namespace $script:App
        } finally {           
            Save-Chart -Chart $chart
        }
    }

    'Tag' {
        Confirm-Service
        Confirm-Parameter -Name 'Tag' -Value $Tag

        helm chart save `
            $script:ServicePath `
            "$($script:Registry).azurecr.io/helm/$($script:Image):$Tag"
    }

    'Push' {
        Confirm-Service
        Confirm-Parameter -Name 'Tag' -Value $Tag        
        $chart = Set-Chart

        try {
            helm chart push `
                "$($script:Registry).azurecr.io/helm/$($script:Image):$Tag"
        } finally {           
            Save-Chart -Chart $chart
        }
    }   

    'Pull' {
        Confirm-Service
        Confirm-Parameter -Name 'Tag' -Value $Tag
        
        helm chart remove `
            "$($script:Registry).azurecr.io/helm/$($script:Image):$Tag"

        helm chart pull `
            "$($script:Registry).azurecr.io/helm/$($script:Image):$Tag"
    }  
    
    'Pack' {
        Confirm-Service
        Confirm-Parameter -Name 'ChartVersion' -Value $ChartVersion
        Confirm-Parameter -Name 'AppVersion' -Value $AppVersion

        helm package `
            --version $ChartVersion `
            --app-version $AppVersion `
            $script:Image
    }

    'Remove' {
        Confirm-Service
        Confirm-Parameter -Name 'Tag' -Value $Tag
        
        helm chart remove `
            "$($script:Registry).azurecr.io/helm/$($script:Image):$Tag"
    }   

    'Export' {
        Confirm-Service
        Confirm-Parameter -Name 'Tag' -Value $Tag
        Confirm-Parameter -Name 'Folder' -Value $Folder

        helm chart export `
            "$($script:Registry).azurecr.io/helm/$($script:Image):$Tag" `
            --destination $Folder
    } 
}
