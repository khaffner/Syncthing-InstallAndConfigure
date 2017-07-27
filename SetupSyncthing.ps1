Function Install-Syncthing {
    [CmdletBinding()]
    Param (
        [String]$NssmFolder      = "$env:windir\System32\",
        [String]$SyncthingFolder = $env:ProgramFiles,
        [Parameter(Mandatory)][String]$ServiceUser,
        [Parameter(Mandatory)][String]$ServicePassword
    )

    Begin {
        $BaseUrlNSSM = 'https://nssm.cc'
        $BaseUrlSyncthing = 'https://github.com/syncthing/syncthing/releases'
    }

    Process {
        #Get NSSM
        if(!(Test-Path "$NssmFolder\nssm.exe")) {
            Invoke-WebRequest ($BaseUrlNSSM+((Invoke-WebRequest "$BaseUrlNSSM/download").Links | where href -Like /ci*zip | select -First 1).href) -OutFile $env:TEMP\nssm.zip
            Expand-Archive -Path "$env:TEMP\nssm.zip" -DestinationPath $env:TEMP\nssm -Force
            Copy-Item -Path "$env:TEMP\nssm\*\win64\nssm.exe" -Destination $NssmFolder -Force
        }

        #Get Syncthing
        if(!(Test-Path "$SyncthingFolder\Syncthing\Syncthing.exe")) {
            Invoke-WebRequest ("https://github.com"+((Invoke-WebRequest $BaseUrlSyncthing).Links | Where href -like "*windows-amd64*" | where href -NotLike '*rc*' | select -First 1).href) -OutFile $env:TEMP\syncthing.zip
            Expand-Archive -Path $env:TEMP\syncthing.zip -DestinationPath $env:ProgramFiles -Force
            Get-ChildItem -Path $env:ProgramFiles -Filter 'Syncthing-windows*' | Rename-Item -NewName Syncthing -Force
        }
        
        #Make Service for Syncthing
        nssm install Syncthing "$SyncthingFolder\Syncthing\syncthing.exe" "-no-restart -no-browser -home=""$SyncthingFolder\Syncthing"""
        nssm set Syncthing AppExit Default Exit
        nssm set Syncthing AppExit 0 Exit
        nssm set Syncthing AppExit 3 Restart
        nssm set Syncthing AppExit 4 Restart
        nssm set Syncthing ObjectName .\$ServiceUser $ServicePassword
        Set-Service -Name Syncthing -StartupType Automatic
    }

    End {
        #Start Syncting
        Start-Service -Name Syncthing
    }
}
