Function New-KubeConfigLookup{
    [cmdletbinding()]
    param(
        $Payload
    )
    $tpl = @{}
    foreach($Cluster in $Payload.kubernetes.PSObject.Properties.Name){
        $tpl.Add($Cluster,
            @{
                Server = ""
                Token =""
            }
        )
    }
    $tpl | ConvertTo-Json | Out-File -Path "$HOME/maps.json"
}

Function New-KubeConf{
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)]
        [String]
        $ClusterName,
        
        [Parameter(Mandatory)]
        [String]
        $Server,
        
        [Parameter(Mandatory)]
        [String[]]
        $Namespace,

        [Parameter()]
        [String]
        $CACert,

        [Parameter(Mandatory)]
        [String]
        $Token
    )
    
    
    
    foreach($ns in $Namespace){
        $ContextName = "$($ClusterName)://$ns"
        $UserId = "$($ClusterName)-$ns"
        & kubectl config set-credentials $UserId --token=$Token | Out-Null
        Write-Verbose "Setting $ContextName"
        Write-Verbose "Setting new cluster $ClusterName with server $Server"
        & kubectl config set-cluster $ClusterName --server="$Server" --insecure-skip-tls-verify=true | Out-Null
        Write-Verbose "Setting new context $($ClusterName)://$ns"
        & kubectl config set-context $ContextName --cluster=$ClusterName --user=$UserId --namespace $ns  | Out-Null
        if($CACert){
            Write-Verbose "Setting CACert to $ClusterName"
            & kubectl config set clusters.$($ClusterName).certificate-authority-data $CACert  | Out-Null
        }
    }
}


$Payload = Get-Content -Path "$HOME/config.json" -Raw | ConvertFrom-Json
$Lookup = Get-Content -Path "$HOME/maps.json" -Raw | ConvertFrom-Json



if(Test-Path -Path "$HOME/.kube/config"){
    $date1 = Get-Date -Date "01/01/1970"
    $date2 = Get-Date
    $NewName = "config.$((New-TimeSpan -Start $date1 -End $date2).TotalSeconds).bkup"
    Write-Host "Backed up config" $NewName -ForegroundColor Green
    Move-Item -Path "$HOME/.kube/config" -Destination "$HOME/.kube/$NewName"
}

foreach($Cluster in $Payload.kubernetes.PSObject.Properties.Name){
    $Split = $Cluster.Split('-')
    if($Lookup.$Cluster){
        foreach($namespace in $Payload.kubernetes.$Cluster.groups.managed){
            $KubeConf = @{
                ClusterName = $Cluster
                Server = $Lookup.$Cluster.Server
                Namespace = $namespace.Split("-")[0]
                Token = $Lookup.$Cluster.Token
            }
            Write-Host "Adding $($KubeConf.ClusterName)://$($KubeConf.Namespace)"
            New-KubeConf @KubeConf
        }
    }else{
        Write-Error "Cluster $Cluster not found in maps.json!"
    }
}