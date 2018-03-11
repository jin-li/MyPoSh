# Add path to environment
$env:Path += ";C:\Program Files\WindowsPowerShell\Scripts;" 
# $env:PSModulePath += ";C:\Users\LI Jin\Documents\WindowsPowerShell\Modules;C:\Program Files\WindowsPowerShell\Modules"
$env:PYTHONIOENCODING='utf-8'

Set-PSReadLineOption -HistoryNoDuplicates;

$ProjectDirectory = 'C:\Projects';

# alias set by lijin
Set-Alias pulseaudio ~\AppData\Roaming\PulseAudio\bin\pulseaudio.exe
set-Alias gh Get-Help;
# Set-Alias cd Push-Location -Option AllScope;
Set-Alias cdb Pop-Location -Option AllScope;
Set-Alias ipy ipython

Set-Alias which C:\Windows\System32\where.exe


# some special characters
$lTriangle         = [char]0xe0b2;
$rTriangle         = [char]0xe0b0;
$Branch            = [char]0xe0a0;
$Lock              = [char]0xe0a2;
$lAngle            = [char]0xe0b3;
$rAngle            = [char]0xe0b1;
$lArrow            = [char]0x2190;
$rArrow            = [char]0x2192;
$UpArrow           = [char]0x2191;
$DownArrow         = [char]0x2193;
$LeftRightArrow    = [char]0x2194;
$UpDownArrow       = [char]0x2195;
$Tick              = [char]0x2713;
$ThickTick         = [char]0x2714;
$Vote              = [char]0x2717;
$ThickVote         = [char]0x2718;
$Lightning         = [char]0x26A1;
$EmptyFlag         = [char]0x2690;
$FullFlag          = [char]0x2691;
$Star              = [char]0x2605;
$TripleBar         = [char]0x2261;
$Cross             = [char]0x00d7;
$ThickCross        = [char]0x2716;


function cdp {
	[CmdletBinding()]
    Param()

    DynamicParam {
        # Set the dynamic parameters' name
        $ParameterName = 'Path';

        # Create the dictionary
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary;

        # Generate and set the ValidateSet
        $DirectorySet = Get-ChildItem -Path $ProjectDirectory -Directory | Select-Object -ExpandProperty Name;
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($DirectorySet);

        # Create and set the parameters' attributes
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute;
        $ParameterAttribute.Position = 0;

        # Create the collection of attributes
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute];
		$AttributeCollection.Add($ValidateSetAttribute);
		$AttributeCollection.Add($ParameterAttribute);

        # Create and return the dynamic parameter
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection);
        $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter);

        return $RuntimeParameterDictionary;
    }

    Begin {
        # Bind the parameter to a friendly variable
        $ProjectName = $PsBoundParameters[$ParameterName];
    }

    Process {
		cd $ProjectDirectory\$ProjectName;
    }
}

function cdh {
    cd ~;
}

function Right-Write ($Content, $fgColor, $bgColor){
    $startposx = $Host.UI.RawUI.windwsize.width - $Content.length;
    $startposy = $Host.UI.RawUI.CursorPosition.Y;
    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates $startposx,$startposy;
    $host.UI.RawUI.ForegroundColor = $fgColor;
    $host.UI.RawUI.BackgroundColor = $bgColor;
    $Host.UI.Write($Content);
}

function Get-Elapsed {
    <#
    .Synopsis
        Get the time span elapsed during the execution of command (by default the previous command)
    .Description
        Calls Get-History to return a single command and returns the difference between the Start and End execution time
    #>
    [CmdletBinding()]
    param(
        # The command ID to get the execution time for (defaults to the previous command)
        [Parameter()]
        [int]$Id,

        # A Timespan format pattern such as "{0:ss\.ffff}"
        [Parameter()]
        [string]$Format = "{0:h\:mm\:ss\.ffff}"
    )
    $null = $PSBoundParameters.Remove("Format")
    $LastCommand = Get-History -Count 1 @PSBoundParameters
    if(!$LastCommand) { return "" }
    $Duration = $LastCommand.EndExecutionTime - $LastCommand.StartExecutionTime
    $Format -f $Duration
}

Push-Location (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent);

Import-Module posh-git;

$Global:GitPromptSettings.BeforeText = $($Branch);
$Global:GitPromptSettings.BeforeForegroundColor = [ConsoleColor]::DarkMagenta;
$Global:GitPromptSettings.BeforeBackgroundColor = [ConsoleColor]::White;

# $Global:GitPromptSettings.DelimText = " $([char]0xb7)";
$Global:GitPromptSettings.DelimText = $($Vote);
$Global:GitPromptSettings.DelimForegroundColor = [ConsoleColor]::Red;
$Global:GitPromptSettings.DelimBackgroundColor = [ConsoleColor]::White;

$Global:GitPromptSettings.AfterText = ' ';
$Global:GitPromptSettings.AfterForegroundColor = [ConsoleColor]::DarkGray;
$Global:GitPromptSettings.AfterBackgroundColor = [ConsoleColor]::White;

$Global:GitPromptSettings.LocalStagedStatusForegroundColor = [ConsoleColor]::DarkGray;
$Global:GitPromptSettings.LocalStagedStatusBackgroundColor = [ConsoleColor]::White;

$Global:GitPromptSettings.BranchUntrackedSymbol = $($Lightening);
$Global:GitPromptSettings.BranchForegroundColor = [ConsoleColor]::Red;
$Global:GitPromptSettings.BranchBackgroundColor = [ConsoleColor]::White;

# $Global:GitPromptSettings.BranchIdenticalStatusToSymbol = $($ThickVote);
$Global:GitPromptSettings.BranchIdenticalStatusToForegroundColor = [ConsoleColor]::DarkGreen;
$Global:GitPromptSettings.BranchIdenticalStatusToBackgroundColor = [ConsoleColor]::White;

$Global:GitPromptSettings.BranchBehindAndAheadStatusForegroundColor = [ConsoleColor]::DarkYellow;
$Global:GitPromptSettings.BranchBehindAndAheadStatusBackgroundColor = [ConsoleColor]::White;

$Global:GitPromptSettings.BranchBehindStatusForegroundColor = [ConsoleColor]::DardRed;
$Global:GitPromptSettings.BranchBehindStatusBackgroundColor = [ConsoleColor]::White;

$Global:GitPromptSettings.BranchAheadStatusForegroundColor = [ConsoleColor]::DarkGreen;
$Global:GitPromptSettings.BranchAheadStatusBackgroundColor = [ConsoleColor]::White;

$Global:GitPromptSettings.LocalWorkingStatusBackgroundColor = [ConsoleColor]::White;
$Global:GitPromptSettings.BeforeIndexBackgroundColor = [ConsoleColor]::White;
$Global:GitPromptSettings.IndexBackgroundColor = [ConsoleColor]::White;
$Global:GitPromptSettings.WorkingBackgroundColor = [ConsoleColor]::White;

$Global:GitPromptSettings.EnableWindowTitle = $false;
$Global:GitPromptSettings.ShowStatusWhenZero = $false;


# Set up a simple prompt, adding the git prompt parts inside git repos
function global:prompt {
    $realLASTEXITCODE = $Global:LASTEXITCODE;
    $hostline = "# $env:Username@$env:UserDomain ";

<#
    $Content = $(Get-Date -f "T");
    $startposx = $Host.UI.RawUI.windwsize.width - $Content.length;
    $startposy = $Host.UI.RawUI.CursorPosition.Y;
    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates $startposx,$startposy;
    $host.UI.RawUI.ForegroundColor = White;
    $host.UI.RawUI.BackgroundColor = Blue;
    $Host.UI.Write($Content);
#>
    Write-Host " "
<#
    [string]$Format = "{0:h\:mm\:ss\.ffff}"
    $null = PSBoundParameters.Remove("Format")
    $LastCommand = Get-History -Count 1 @PSBoundParameters
    if(!$LastCommand) { return "" }
    $Duration = $LastCommand.EndExecutionTime - $LastCommand.StartExecutionTime
#>
    $OriginalFGColor = $Host.UI.RawUI.ForegroundColor;
    $OriginalBGColor = $Host.UI.RawUI.BackgroundColor;
#    $message = "This text is right aligned"
    $CurrentTime = $(Get-Date -f "T") 
    $LastRunTime = $(Get-Elapsed)
    $startposx = $Host.UI.RawUI.windowsize.width - $CurrentTime.length - $LastRunTime.length - 2;
    $startposy = $Host.UI.RawUI.CursorPosition.Y - 2;
    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates $startposx,$startposy
<#    if($MyInvocation.HistoryId -ne 1) {
        $TimeBackground = Gray
    } else {
        $TimeBackground = $OriginalBGColor
    }
#>
    Write-Host $($lTriangle) -ForegroundColor Gray -NoNewline
    Write-Host $LastRunTime -ForegroundColor Black -BackgroundColor Gray -NoNewline
    $startposx = $Host.UI.RawUI.windowsize.width - $CurrentTime.length - 1;
    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates $startposx,$startposy
    Write-Host $($lTriangle) -ForegroundColor DarkGray -Background Gray -NoNewline
    $host.UI.RawUI.ForegroundColor = "White"
    $Host.UI.RawUI.BackgroundColor = "DarkGray"
    $Host.UI.Write($CurrentTime)
# $Host.UI.Write($message)
    $host.UI.RawUI.ForegroundColor = $OriginalFGColor;
    $host.UI.RawUI.BackgroundColor = $OriginalBGColor;

    # set error notification
    if ($realLASTEXITCODE -eq 0) {
        $hostColor = [ConsoleColor]::Blue;
        Write-Host $hostline -ForegroundColor White -BackgroundColor $hostColor -NoNewLine;
    } else {
        $hostColor = [ConsoleColor]::DarkRed;
        Write-Host $hostline -ForegroundColor White -BackgroundColor $hostColor -NoNewLine;
        Write-Host $($rTriangle) -ForegroundColor $hostColor -BackgroundColor Blue -NoNewLine;
# $hostline += "Error:(0x$('{0:X0}' -f $realLASTEXITCODE)) ";
        Write-Host "Error: $realLASTEXITCODE" -ForegroundColor Red -BackgroundColor Blue -NoNewline;
# $hostline += "Error: $realLASTEXITCODE";
        $Global:LASTEXITCODE = 0;
    }

# Write-Host $hostline -ForegroundColor White -BackgroundColor $hostColor -NoNewLine;
    if($pushd = (Get-Location -Stack).count) { 
        Write-Host "$rTriangle" -ForegroundColor Blue -BackgroundColor Cyan -NoNewLine; 
        Write-Host "$([char]187)$pushd" -ForegroundColor Black -BackgroundColor Cyan -NoNewLine; 
        Write-Host "$rTriangle" -ForegroundColor Cyan -BackgroundColor DarkBlue -NoNewLine; 
    } else { 
        Write-Host "$([char]0xe0b0)" -ForegroundColor Blue -BackgroundColor DarkBlue -NoNewline;
    }

    $realFolderName = $(Get-Location);
    if ($pwd.ProviderPath -eq $env:UserProfile) {
        $folderName = '~';
    } else {
        if(([string]$(Get-Location)).length -ge 90) {
            $folderName = Split-Path $pwd -leaf 
        } else {
            $folderName = $(Get-Location);
        }
    }

    Write-Host "$folderName " -ForegroundColor White -BackgroundColor DarkBlue -NoNewline;
    $gitStatus = Get-GitStatus;

    if ($gitStatus -ne $null) {
        Write-Host "$([char]0xe0b0)" -ForegroundColor DarkBlue -BackgroundColor White -NoNewline;
        Write-GitStatus $gitStatus;
        Write-Host "$([char]0xe0b0)" -ForegroundColor White;
    } else {
        Write-Host "$([char]0xe0b0)" -ForegroundColor DarkBlue;
    }

    Write-Host $MyInvocation.HistoryId -ForegroundColor Black -BackgroundColor Cyan -NoNewline;
    Write-Host "$([char]0xe0b0)" -ForegroundColor Cyan -NoNewline;
    Write-Output " ";

    try {
      #  & "$env:ConEmuBaseDir\ConEmuC.exe" "/GUIMACRO", 'Rename(0,@"'$realFolderName'")' > $null;
    } catch { }
}

Pop-Location;


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
    '\.(py|pl|cs|rb|h|cpp|c|tex|cls)$', $regex_opts)
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

# iex "$(thefuck --alias)"

Start-Transcript 'C:\Users\lijin\Documents\WindowsPowerShell\PSlogfile.txt' -Append

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

function desk {
    cd ~/Desktop
}

function proj {
	cd 'C:\Users\lijin\Documents\Visual Studio 2017\Projects\'
}

function doc{
    cd ~/Documents
}