#Get NSSM
if(!(Test-Path "C:\Windows\System32\nssm.exe")) {
    $BaseUrlNSSM = 'https://nssm.cc'
    Invoke-WebRequest ($BaseUrlNSSM+((Invoke-WebRequest "$BaseUrlNSSM/download").Links | where href -Like /ci*zip | select -First 1).href) -OutFile $env:TEMP\nssm.zip
    Expand-Archive -Path $env:TEMP\nssm.zip -DestinationPath $env:TEMP\nssm -Force
    Copy-Item -Path $env:TEMP\nssm\*\win64\nssm.exe -Destination C:\Windows\System32 -Force
}

#Get Syncthing
if(!(Test-Path 'C:\Program Files\Syncthing\Syncthing.exe')) {
    $BaseUrlSyncthing = 'https://github.com/syncthing/syncthing/releases'
    Invoke-WebRequest ("https://github.com"+((Invoke-WebRequest $BaseUrlSyncthing).Links | Where href -like "*windows-amd64*" | where href -NotLike '*rc*' | select -First 1).href) -OutFile $env:TEMP\syncthing.zip
    Expand-Archive -Path $env:TEMP\syncthing.zip -DestinationPath $env:ProgramFiles -Force
    Get-ChildItem -Path $env:ProgramFiles -Filter 'Syncthing-windows*' | Rename-Item -NewName Syncthing -Force
}

#Make Service for Syncthing
nssm remove Syncthing confirm
nssm install Syncthing "C:\Program Files\Syncthing\syncthing.exe" '-no-restart -no-browser -home=""C:\Program Files\Syncthing""'
nssm set Syncthing AppExit Default Exit
nssm set Syncthing AppExit 0 Exit
nssm set Syncthing AppExit 3 Restart
nssm set Syncthing AppExit 4 Restart
Set-Service -Name Syncthing -StartupType Automatic

#Start Syncting
Start-Service -Name Syncthing
