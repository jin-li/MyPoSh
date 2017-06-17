# Source: https://www.powershellgallery.com/packages/GithubConnect/0.3/Content/GithubConnect.psm1
Function Connect-Github {
param (
    [Parameter(Mandatory=$false)]
    [PSCredential]$GithubCredentials,
    [Parameter(Mandatory=$false)]
    [string]$OneTimePassword
)

<# 
.Synopsis 
   Connects PowerShell to the Github API 
.DESCRIPTION 
   This function will connect the current PowerShell session to the Github API via Basic Authentication. 2FA is currently not yet supported. 
   The user name and password have to be provided on the command line as Github is not following RFC standards to the full extent: https://developer.github.com/v3/auth/ 
   If you don't want to provide the password on the command line, don't provide it and enter it in the prompt. 
.EXAMPLE 
   Connect-Github 
.EXAMPLE 
   Connect-Github -GithubCredentials $(Get-Credential) 
.EXAMPLE 
   Connect-Github -OneTimePassword 123456 
.EXAMPLE 
   $creds = Get-Credential 
   Connect-Github -GithubCredentials $creds -OneTimePassword 123456 
#>

    if (-not $GithubCredentials) {
        $GithubCredentials = (Get-Credential -Message 'Please enter the Github User credentials')
    }

    $githubusername = $GithubCredentials.UserName
    $githubpassword = $GithubCredentials.GetNetworkCredential().Password

    $AuthString = "{0}:{1}" -f $githubusername,$githubpassword
    $AuthBytes  = [System.Text.Encoding]::Ascii.GetBytes($AuthString)
    $global:BasicCreds = [Convert]::ToBase64String($AuthBytes)

    $githuburi = 'https://api.github.com/user' 
    if ($OneTimePassword) {
        try {
            Invoke-WebRequest -Uri $GitHubUri -Headers @{"Authorization"="Basic $BasicCreds"; "X-Github-OTP" = $OneTimePassword} -Verbose -ErrorAction Stop
        }
        catch {
            Write-Error -Message $_
        }
    }
    else {
        try {
            Invoke-WebRequest -Uri $GitHubUri -Headers @{"Authorization"="Basic $BasicCreds"} -Verbose -ErrorAction Stop
        }
        catch {
            Write-Error -Message $_
        }        
    }
}

Function New-GithubRepository {
param (
    [Parameter(Mandatory= $true)]
    [string]$repository_name,
    [Parameter(Mandatory= $true)]
    [string]$repository_description,
    [Parameter(Mandatory= $true)]
    [string]$repository_homepage,
    [Parameter(Mandatory= $true)]
    [string]$repository_private,
    [Parameter(Mandatory= $true)]
    [string]$repository_has_issues,
    [Parameter(Mandatory= $true)]
    [string]$repository_has_wiki,
    [Parameter(Mandatory= $true)]
    [string]$repository_has_downloads
)

    if (-not ($BasicCreds)) {
        throw 'Please run Connect-Github first to get an authentication token for Github'
    }

$newrepo = @"
{ 
    "name": "$repository_name", 
    "description": "$repository_description", 
    "homepage": "$repository_homepage", 
    "private": $repository_private, 
    "has_issues": $repository_has_issues, 
    "has_wiki": $repository_has_wiki, 
    "has_downloads": $repository_has_downloads 
} 
"@

    try {
        Invoke-WebRequest -Body $newrepo -Uri https://api.github.com/user/repos -Method Post -Headers @{"Authorization"="Basic $BasicCreds"} -Verbose -ErrorAction Stop
    }
    catch {
        Write-Error $_
    }

}

Function Remove-GithubRepository {
param (
    [Parameter(Mandatory=$true)]
    [string]$githubusername,
    [Parameter(Mandatory=$true)]
    [string]$Repository_Name
)

    if (-not ($BasicCreds)) {
        throw 'Please run Connect-Github first to get an authentication token for Github'
    }

    try {
        Invoke-WebRequest -Uri https://api.github.com/repos/$githubusername/$Repository_Name -Method Delete -Headers @{"Authorization"="Basic $BasicCreds"} -Verbose -ErrorAction Stop
    }
    catch {
        Write-Error -Message $_
    }

}

Function Get-GithubPublicRepositories {
param (
    [parameter(mandatory=$false)]
    [string] $githubusername
)
    try {
        $json = Invoke-WebRequest -Uri https://api.github.com/users/$githubusername/repos -Method Get -ErrorAction Stop
    }
    catch {
        Write-Error -Message $_
    }
    
    [System.Collections.ArrayList]$repos = @()

    $con_json = ConvertFrom-Json -InputObject $json.Content
    foreach ($obj in $con_json) {
        $repo = New-Object -TypeName PSObject
        Add-Member -InputObject $repo -MemberType NoteProperty -Name 'Name' -Value $obj.name
        Add-Member -InputObject $repo -MemberType NoteProperty -Name 'Description' -Value $obj.description
        $repos += $repo
    }
    $repos
}

Function Get-GithubOwnRepositories {
param (

)
    
    if (-not ($BasicCreds)) {
        throw 'Please run Connect-Github first to get an authentication token for Github'
    }

    try {
        $json = Invoke-WebRequest -Uri https://api.github.com/user/repos -Method Get -ErrorAction Stop
    }
    catch {
        Write-Error -Message $_
    }
    
    [System.Collections.ArrayList]$repos = @()

    $con_json = ConvertFrom-Json -InputObject $json.Content
    foreach ($obj in $con_json) {
        $repo = New-Object -TypeName PSObject
        Add-Member -InputObject $repo -MemberType NoteProperty -Name 'Name' -Value $obj.name
        Add-Member -InputObject $repo -MemberType NoteProperty -Name 'Description' -Value $obj.description
        $repos += $repo
    }
    $repos
}

New-CommandWrapper Out-Default -Process {
  $regex_opts = ([System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
  $compressed = New-Object System.Text.RegularExpressions.Regex(
    '\.(zip|tar|gz|rar|jar|war)$', $regex_opts)
  $executable = New-Object System.Text.RegularExpressions.Regex(
    '\.(exe|bat|cmd|msi|ps1|psm1|vbs|reg)$', $regex_opts)
  $text_files = New-Object System.Text.RegularExpressions.Regex(
    '\.(txt|doc|docx|vim|cfg|conf|ini|csv|log)$', $regex_opts)
  $image_files = New-Object System.Text.RegularExpressions.Regex(
    '\.(bmp|jpg|png|gif|jpeg|ps)$', $regex_opts)
  $media_files = New-Object System.Text.RegularExpressions.Regex( 
    '\.(mp4|mpg|mkv|avi|mp3|wave|ape|flac)$', $regex_opts)
  $source_files = New-Object System.Text.RegularExpressions.Regex( 
    '\.(py|pl|cs|rb|h|cpp|c)$', $regex_opts)
  $office_files = New-Object System.Text.RegularExpressions.Regex( 
    '\.(ppt|pptx|pdf|xl|xlsx|xls)$', $regex_opts)

  if(($_ -is [System.IO.DirectoryInfo]) -or ($_ -is [System.IO.FileInfo]))
  {
    if(-not ($notfirst))
    {
      Write-Host "`n    Directory: " -noNewLine
      Write-Host "$(pwd)`n" -foregroundcolor "Cyan"
      Write-Host "Mode        Last Write Time       Length   Name"
      Write-Host "----        ---------------       ------   ----"
      $notfirst=$true
    }

    if ($_ -is [System.IO.DirectoryInfo])
    {
      Write-Host ("{0}   {1}                {2}" -f $_.mode, ([String]::Format("{0,10} {1,8}", $_.LastWriteTime.ToString("d"), $_.LastWriteTime.ToString("t"))), $_.name) -ForegroundColor "Cyan"
    }
    else
    {
      if ($compressed.IsMatch($_.Name)) {
        $color = "DarkGreen"
      } elseif ($executable.IsMatch($_.Name)) {
        $color =  "Red"
      } elseif ($text_files.IsMatch($_.Name)) {
        $color =  "Yellow"
      } elseif ($image_files.IsMatch($_.Name)) {
        $color =  "DarkCyan"
      } elseif ($media_files.IsMatch($_.Name)) {
        $color =  "DarkGray"
      } elseif ($source_files.IsMatch($_.Name)) {
        $color =  "Magenta"
      } elseif ($office_files.IsMatch($_.Name)) {
        $color =  "Green"
      } else {
        $color = "White"
      }
      Write-Host ("{0}   {1}   {2,10}   {3}" -f $_.mode, ([String]::Format("{0,10} {1,8}", $_.LastWriteTime.ToString("d"), $_.LastWriteTime.ToString("t"))), $_.length, $_.name) -ForegroundColor $color
    }
    $_ = $null
  }
} -end {
 # Write-Host
}

function Get-DirSize
{
  param ($dir)
  $bytes = 0
  $count = 0

  Get-Childitem $dir | Foreach-Object {
    if ($_ -is [System.IO.FileInfo])
    {
      $bytes += $_.Length
      $count++
    }
  }

  Write-Host "`n    " -NoNewline

  if ($bytes -ge 1KB -and $bytes -lt 1MB) {
    Write-Host ("" + [Math]::Round(($bytes / 1KB), 2) + " KB") -ForegroundColor "White" -NoNewLine
  } elseif ($bytes -ge 1MB -and $bytes -lt 1GB) {
    Write-Host ("" + [Math]::Round(($bytes / 1MB), 2) + " MB") -ForegroundColor "White" -NoNewLine
  } elseif ($bytes -ge 1GB) {
    Write-Host ("" + [Math]::Round(($bytes / 1GB), 2) + " GB") -ForegroundColor "White" -NoNewLine
  } else {
    Write-Host ("" + $bytes + " bytes") -ForegroundColor "White" -NoNewLine
  }
  Write-Host " in " -NoNewline
  Write-Host $count -ForegroundColor "White" -NoNewline
  Write-Host " files"
}

function Get-DirWithSize
{
  param ($dir)
  Get-Childitem $dir
  Get-DirSize $dir
}

Remove-Item alias:dir
Remove-Item alias:ls
Set-Alias dir Get-DirWithSize
Set-Alias ls Get-DirWithSize

