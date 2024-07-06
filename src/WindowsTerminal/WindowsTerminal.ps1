function Set-OhMyPosh-Theme {
  $DotfilesOhMyPoshThemePath = Join-Path -Path $DotfilesWorkFolder -ChildPath "WindowsTerminal" | Join-Path -ChildPath ".oh-my-posh-custom-theme.omp.json";

  Write-Host "Setting Oh My Posh theme path in PowerShell profile." -ForegroundColor "Green";
  
  $initCommand = "oh-my-posh init pwsh --config `"$DotfilesOhMyPoshThemePath`" | Invoke-Expression"
  Add-Content -Path $Profile -Value $initCommand
}

function Set-PowerShell-Profile {
  $DotfilesWindowsTerminalProfilePath = Join-Path -Path $DotfilesWorkFolder -ChildPath "WindowsTerminal" | Join-Path -ChildPath "Microsoft.PowerShell_profile.ps1";

  if (-not (Test-Path -Path $Profile)) {
    Write-Host "Creating empty PowerShell profile:" -ForegroundColor "Green";
    New-Item -Path $Profile -ItemType "file" -Force;
  }
  
  Write-Host "Copying PowerShell profile:" -ForegroundColor "Green";
  Copy-Item $DotfilesWindowsTerminalProfilePath -Destination $Profile -Force;
  
  Set-OhMyPosh-Theme
  
  Write-Host "Activating PowerShell profile:" -ForegroundColor "Green";
  . $Profile;
}

function Set-WindowsTerminal-Settings {
  $WindowsTerminalSettingsFilePath = Join-Path -Path $env:LOCALAPPDATA -ChildPath "Packages" | Join-Path -ChildPath "Microsoft.WindowsTerminal_8wekyb3d8bbwe" | Join-Path -ChildPath "LocalState" | Join-Path -ChildPath "settings.json";
  $DotfilesWindowsTerminalSettingsPath = Join-Path -Path $DotfilesWorkFolder -ChildPath "WindowsTerminal" | Join-Path -ChildPath "settings.json";
  $WorkspaceFolder = Join-Path -Path $Config.WorkspaceDisk -ChildPath "Workspace";

  Write-Host "Copying Windows Terminal settings:" -ForegroundColor "Green";
  Copy-Item $DotfilesWindowsTerminalSettingsPath -Destination $WindowsTerminalSettingsFilePath;

  Write-Host "Configuring Windows Terminal starting directory:" -ForegroundColor "Green";
  
  (Get-Content -path $WindowsTerminalSettingsFilePath) -replace "__STARTING_WINDOWS_DIRECTORY__", ($WorkspaceFolder | ConvertTo-Json) | Set-Content -Path $WindowsTerminalSettingsFilePath;

  $UbuntuStartingDirectory = wsl wslpath -w "~/Workspace";
  (Get-Content -path $WindowsTerminalSettingsFilePath) -replace "__STARTING_UBUNTU_DIRECTORY__", ($UbuntuStartingDirectory | ConvertTo-Json) | Set-Content -Path $WindowsTerminalSettingsFilePath;

  Write-Host "Windows Terminal was successfully configured." -ForegroundColor "Green";
}

function Open-Close-WindowsTerminal {
  # Open and close Windows Terminal as admin to load the profile
  Write-Host "Opening Windows Terminal for 10 seconds:" -ForegroundColor "Green";
  wt new-tab PowerShell -c "Set-ExecutionPolicy Unrestricted;";

  Start-Sleep -Seconds 10;

  Write-Host "Closing Windows Terminal:" -ForegroundColor "Green";
  Stop-Process -Name "WindowsTerminal" -Force;
}

Install-Module -Name "oh-my-posh";
Install-Module -Name "posh-git" -Repository "PSGallery";
Install-Module -Name "Terminal-Icons" -Repository "PSGallery";
Install-Module -Name "PSWebSearch" -Repository "PSGallery";
Install-Module -Name "PSReadLine" -Repository "PSGallery" -RequiredVersion 2.1.0;
Set-OhMyPosh-Theme;
Set-PowerShell-Profile;
Set-WindowsTerminal-Settings;
Open-Close-WindowsTerminal;