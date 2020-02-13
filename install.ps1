<#PSScriptInfo

.VERSION 1.0.0

#>

<#

.SYNOPSIS
    Installs or updates git for windows.
.DESCRIPTION
    Borrowed heavily from https://github.com/PowerShell/vscode-powershell/blob/develop/scripts/Install-VSCode.ps1. Sourcecode available at https://github.com/tomlarse/Install-Git
    Install and run with Install-Script Install-Git; Install-Git.ps1
.EXAMPLE
    Install-Git.ps1
.NOTES
    This script is licensed under the MIT License:
    Copyright (c) Tom-Inge Larsen
    Copyright (c) Microsoft Corporation.
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
#>
Param()
if (!($IsLinux -or $IsOSX))
{

    $turbotExePath = "C:\Program Files\Turbot\bin\turbot"
    $setTurbotPathInEnvVars = $True
    #Added TLS negotiation Fork jmangan68
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;
    $newversionname = (Invoke-RestMethod https://api.github.com/repos/turbot/cli/releases/latest).name
    foreach ($asset in (Invoke-RestMethod https://api.github.com/repos/turbot/cli/releases/latest).assets)
    {
        if ($asset.name -match 'turbot_cli_\d*.\d*.\d*_windows_amd64.zip')
        {
            $dlurl = $asset.browser_download_url
            $newver = $asset.name
        }
    }

    try
    {
        $ProgressPreference = 'SilentlyContinue'

        if (!(Test-Path $turbotExePath))
        {
            Write-Host "`nDownloading latest stable turbot-cli..." -ForegroundColor Yellow
            Remove-Item -Force $env:TEMP\turbot.exe -ErrorAction SilentlyContinue
            Invoke-WebRequest -Uri $dlurl -OutFile $env:TEMP\$newver

            Expand-Archive $env:TEMP\$newver -DestinationPath $turbotExePath -Force

            Write-Host "`nInstalling turbot-cli..." -ForegroundColor Yellow

            $setTurbotPathInEnvVar = $env:Path -match "turbot"
            if (-not $setTurbotPathInEnvVars){
                $env:Path += ";C:\Program Files\Turbot\bin\turbot"
                Write-Host "`n turbot-cli path has set in Env Vars(Path)..."
            }
            turbot --version
        }
        else
        {
            $updateneeded = $false
            Write-Host "`nturbot-cli is already installed. Check if possible update..." -ForegroundColor Yellow

            (turbot --version) -match "(\d*.\d*.\d*)" | Out-Null
            $installedversion = $matches[0].split('.')
            $newversionname -match "(\d*.\d*.\d*)" | Out-Null
            $newversion = $matches[0].split('.')

            if (($newversion[0] -gt $installedversion[0]) -or ($newversion[0] -eq $installedversion[0] -and $newversion[1] -gt $installedversion[1]) -or ($newversion[0] -eq $installedversion[0] -and $newversion[1] -eq $installedversion[1] -and $newversion[2] -gt $installedversion[2]))
            {
                $updateneeded = $true
            }

            if ($updateneeded)
            {

                Write-Host "`nUpdate available. Downloading latest stable turbot-cli..." -ForegroundColor Yellow
                Remove-Item -Force $turbotExePath -ErrorAction SilentlyContinue
                Invoke-WebRequest -Uri $dlurl -OutFile $env:TEMP\$newver

                Expand-Archive $env:TEMP\$newver -DestinationPath $turbotExePath -Force

                Write-Host "`nInstalling turbot-cli..." -ForegroundColor Yellow

                $sshagentrunning = get-process ssh-agent -ErrorAction SilentlyContinue
                if ($sshagentrunning)
                {
                    Write-Host "`nKilling ssh-agent..." -ForegroundColor Yellow
                    Stop-Process $sshagentrunning.Id
                }
                turbot --version
            }
            else
            {
                Write-Host "`nNo update available. Already running latest version..." -ForegroundColor Yellow
            }

        }
        Write-Host "`nInstallation complete!`n`n" -ForegroundColor Green
    }
    finally
    {
        $ProgressPreference = 'Continue'
    }
}
else
{
    Write-Error "This script is currently only supported on the Windows operating system."
}