﻿Param (
    [string]$Configuration
)

$ScriptDirectory = Split-Path $MyInvocation.MyCommand.Path;

$ProjectDirectory = Split-Path $ScriptDirectory;

if (-not $Configuration)
{
    $Configuration = "Debug"
}

# Generate the path for VCTargetsRoot, need to make sure it ends with a trailing slash
$VCTargetsRoot = (Join-Path -Path $ProjectDirectory -ChildPath (Join-Path -Path "_Output" -ChildPath (Join-Path -Path $Configuration -ChildPath "VCTargetsRoot")));
$VCTargetsRoot = $VCTargetsRoot + [IO.Path]::DirectorySeparatorChar;

Write-Output "Opening the solution from $ScriptDirectory using VCTargetsPath=$VCTargetsRoot";

$RegistryPath = "HKLM:\SOFTWARE\Microsoft\VisualStudio\11.0\Setup\VS";
if (-not (Test-Path -Path $RegistryPath))
{
    $RegistryPath = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\VisualStudio\11.0\Setup\VS";
}
if (-not (Test-Path -Path $RegistryPath))
{
    Write-Error "Unable to find Visual Studio 2012";
    Return -1;
}

# Find Visual Studio 2012
$DevEnvExe = (Join-Path -Path (Get-ItemProperty -Path $RegistryPath).ProductDir `
             (Join-Path -Path "Common7" -ChildPath (Join-Path -Path "IDE" -ChildPath "devenv.exe")));

$Arguments = @();
$Arguments += "`"$(Join-Path -Path $ScriptDirectory -ChildPath "ExampleMinGWProjects.sln")`"";

$env:VCTargetsPath = $VCTargetsRoot;
$env:VCTargetsPath11 = $VCTargetsRoot;
Start-Process -FilePath $DevEnvExe -WorkingDirectory $ScriptDirectory -ArgumentList $Arguments;
