#!/usr/bin/env pwsh
<#
.SYNOPSIS
	Build script that allows switching between different MSVC compiler versions.

.DESCRIPTION
	This script detects available MSVC toolsets and allows you to build the project
	with a specific version to test compatibility.

.PARAMETER MSVCVersion
	Specific MSVC version to use (e.g., "14.16", "14.29", "14.44", "latest")
	If not specified, shows available versions and prompts for selection.

.PARAMETER Clean
	Clean build directory before building.

.PARAMETER BuildType
	Build configuration: Debug or Release (default: Debug)

.EXAMPLE
	.\Build-WithMSVC.ps1 -MSVCVersion "14.16"
	Build with MSVC 14.16 (VS 2017)

.EXAMPLE
	.\Build-WithMSVC.ps1 -MSVCVersion "latest"
	Build with the newest MSVC version

.EXAMPLE
	.\Build-WithMSVC.ps1 -Clean
	Shows menu and cleans before building
#>

param(
	[string]$MSVCVersion = "",
	[switch]$Clean,
	[ValidateSet("Debug", "Release")]
	[string]$BuildType = "Debug"
)

# ANSI color codes
$script:Colors = @{
	Reset = "`e[0m"
	Red = "`e[31m"
	Green = "`e[32m"
	Yellow = "`e[33m"
	Blue = "`e[34m"
	Cyan = "`e[36m"
	Bold = "`e[1m"
}

function Write-ColorOutput {
	param(
		[string]$Message,
		[string]$Color = "Reset"
	)
	Write-Host "$($Colors[$Color])$Message$($Colors.Reset)"
}

function Get-InstalledMSVCVersions {
	Write-ColorOutput "Scanning for installed MSVC versions..." "Cyan"

	$vsInstallPaths = @(
		"C:\Program Files\Microsoft Visual Studio",
		"C:\Program Files (x86)\Microsoft Visual Studio"
	)

	$msvcVersions = @()

	foreach ($basePath in $vsInstallPaths) {
		if (Test-Path $basePath) {
			$msvcPaths = Get-ChildItem -Path "$basePath\*\*\VC\Tools\MSVC" -Directory -ErrorAction SilentlyContinue

			foreach ($msvcPath in $msvcPaths) {
				$versions = Get-ChildItem -Path $msvcPath.FullName -Directory | Where-Object { $_.Name -match '^\d+\.\d+\.\d+' }

				foreach ($version in $versions) {
					$vsYear = switch -Regex ($version.Name) {
						'^14\.0\d'  { "2015" }
						'^14\.1\d'  { "2017" }
						'^14\.2\d'  { "2019" }
						'^14\.3\d'  { "2022" }
						'^14\.4\d'  { "2022" }
						'^14\.5\d'  { "2026" }
						default     { "Unknown" }
					}

					$msvcVersions += [PSCustomObject]@{
						Version = $version.Name
						ShortVersion = $version.Name.Substring(0, 5)
						Path = $version.FullName
						VSYear = $vsYear
						HostPath = Split-Path (Split-Path (Split-Path (Split-Path $version.FullName)))
					}
				}
			}
		}
	}

	# Remove duplicates and sort
	$uniqueVersions = $msvcVersions | Sort-Object Version -Unique | Sort-Object Version

	return $uniqueVersions
}

function Show-MSVCMenu {
	param($Versions)

	Write-ColorOutput "`n========================================" "Bold"
	Write-ColorOutput "  Available MSVC Compiler Versions" "Bold"
	Write-ColorOutput "========================================`n" "Bold"

	for ($i = 0; $i -lt $Versions.Count; $i++) {
		$v = $Versions[$i]
		Write-Host "  $($Colors.Yellow)[$($i + 1)]$($Colors.Reset) MSVC $($Colors.Green)$($v.Version)$($Colors.Reset) (VS $($v.VSYear))"
	}

	Write-Host "`n  $($Colors.Yellow)[0]$($Colors.Reset) Cancel"
	Write-Host ""
}

function Get-VsDevShellPath {
	param($HostPath)

	$possiblePaths = @(
		"$HostPath\Common7\Tools\VsDevCmd.bat",
		"$HostPath\VC\Auxiliary\Build\vcvars64.bat",
		"$HostPath\VC\vcvarsall.bat"
	)

	foreach ($path in $possiblePaths) {
		if (Test-Path $path) {
			return $path
		}
	}

	return $null
}

function Invoke-BuildWithMSVC {
	param(
		[PSCustomObject]$MSVCInfo,
		[string]$BuildType,
		[bool]$CleanBuild
	)

	Write-ColorOutput "`n========================================" "Bold"
	Write-ColorOutput "  Building with MSVC $($MSVCInfo.Version)" "Bold"
	Write-ColorOutput "========================================`n" "Bold"

	$buildDir = "build-msvc-$($MSVCInfo.ShortVersion)"
	$cmakeToolchainArgs = @()

	# Find Visual Studio Developer Command Prompt
	$vsDevShell = Get-VsDevShellPath -HostPath $MSVCInfo.HostPath

	if (-not $vsDevShell) {
		Write-ColorOutput "ERROR: Could not find VS Developer Command Prompt for this version" "Red"
		return $false
	}

	Write-ColorOutput "Using VS DevShell: $vsDevShell" "Cyan"
	Write-ColorOutput "MSVC Path: $($MSVCInfo.Path)" "Cyan"
	Write-ColorOutput "Build Directory: $buildDir" "Cyan"
	Write-ColorOutput "Build Type: $BuildType`n" "Cyan"

	# Clean if requested
	if ($CleanBuild -and (Test-Path $buildDir)) {
		Write-ColorOutput "Cleaning build directory..." "Yellow"
		Remove-Item -Path $buildDir -Recurse -Force
	}

	# Create build directory
	if (-not (Test-Path $buildDir)) {
		New-Item -ItemType Directory -Path $buildDir | Out-Null
	}

	# Set environment variable to force specific MSVC version
	$env:VCToolsVersion = $MSVCInfo.Version

	Write-ColorOutput "`n--- Configuring CMake ---" "Green"

	# Configure CMake
	$cmakeConfigCmd = "cmake -G Ninja -B `"$buildDir`" -DCMAKE_BUILD_TYPE=$BuildType -DCMAKE_CXX_COMPILER=cl -DCMAKE_C_COMPILER=cl"

	Write-ColorOutput "Running: $cmakeConfigCmd" "Cyan"

	& cmd /c "`"$vsDevShell`" && set VCToolsVersion=$($MSVCInfo.Version) && $cmakeConfigCmd 2>&1"

	if ($LASTEXITCODE -ne 0) {
		Write-ColorOutput "`nERROR: CMake configuration failed!" "Red"
		return $false
	}

	Write-ColorOutput "`n--- Building Project ---" "Green"

	# Build
	$cmakeBuildCmd = "cmake --build `"$buildDir`" --config $BuildType"

	Write-ColorOutput "Running: $cmakeBuildCmd`n" "Cyan"

	& cmd /c "`"$vsDevShell`" && set VCToolsVersion=$($MSVCInfo.Version) && $cmakeBuildCmd 2>&1"

	if ($LASTEXITCODE -ne 0) {
		Write-ColorOutput "`nERROR: Build failed with MSVC $($MSVCInfo.Version)!" "Red"
		return $false
	}

	Write-ColorOutput "`n========================================" "Bold"
	Write-ColorOutput "  Build Successful!" "Green"
	Write-ColorOutput "========================================`n" "Bold"

	return $true
}

# Main script execution
Write-ColorOutput "`nMSVC Multi-Version Build Script" "Bold"
Write-ColorOutput "================================`n" "Bold"

$availableVersions = Get-InstalledMSVCVersions

if ($availableVersions.Count -eq 0) {
	Write-ColorOutput "ERROR: No MSVC installations found!" "Red"
	exit 1
}

Write-ColorOutput "Found $($availableVersions.Count) MSVC version(s)`n" "Green"

$selectedVersion = $null

if ($MSVCVersion -eq "latest") {
	$selectedVersion = $availableVersions | Sort-Object Version -Descending | Select-Object -First 1
	Write-ColorOutput "Selected latest version: MSVC $($selectedVersion.Version)" "Green"
}
elseif ($MSVCVersion -ne "") {
	$selectedVersion = $availableVersions | Where-Object { $_.ShortVersion -eq $MSVCVersion -or $_.Version -eq $MSVCVersion } | Select-Object -First 1

	if (-not $selectedVersion) {
		Write-ColorOutput "ERROR: MSVC version '$MSVCVersion' not found!" "Red"
		Write-ColorOutput "Available versions:" "Yellow"
		$availableVersions | ForEach-Object { Write-ColorOutput "  - $($_.Version) ($($_.ShortVersion))" "Yellow" }
		exit 1
	}
}
else {
	Show-MSVCMenu -Versions $availableVersions

	do {
		$selection = Read-Host "Select MSVC version (1-$($availableVersions.Count)) or 0 to cancel"
		$selectionNum = 0
		[int]::TryParse($selection, [ref]$selectionNum) | Out-Null
	} while ($selectionNum -lt 0 -or $selectionNum -gt $availableVersions.Count)

	if ($selectionNum -eq 0) {
		Write-ColorOutput "Build cancelled." "Yellow"
		exit 0
	}

	$selectedVersion = $availableVersions[$selectionNum - 1]
}

# Perform build
$success = Invoke-BuildWithMSVC -MSVCInfo $selectedVersion -BuildType $BuildType -CleanBuild $Clean

if ($success) {
	Write-ColorOutput "Build output location: build-msvc-$($selectedVersion.ShortVersion)\$BuildType" "Cyan"
	exit 0
} else {
	exit 1
}
