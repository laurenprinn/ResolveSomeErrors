#!/usr/bin/env pwsh
<#
.SYNOPSIS
	Quick build test across all installed MSVC versions.

.DESCRIPTION
	Automatically builds the project with all detected MSVC versions
	and reports which versions succeed or fail.

.PARAMETER BuildType
	Build configuration: Debug or Release (default: Debug)

.EXAMPLE
	.\Test-AllMSVC.ps1
	Test build with all MSVC versions
#>

param(
	[ValidateSet("Debug", "Release")]
	[string]$BuildType = "Debug"
)

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Testing All MSVC Versions" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$scriptPath = Join-Path $PSScriptRoot "Build-WithMSVC.ps1"

if (-not (Test-Path $scriptPath)) {
	Write-Host "ERROR: Build-WithMSVC.ps1 not found!" -ForegroundColor Red
	exit 1
}

# Get available versions by running the main script
$availableVersions = @()
$vsInstallPaths = @(
	"C:\Program Files\Microsoft Visual Studio",
	"C:\Program Files (x86)\Microsoft Visual Studio"
)

foreach ($basePath in $vsInstallPaths) {
	if (Test-Path $basePath) {
		$msvcPaths = Get-ChildItem -Path "$basePath\*\*\VC\Tools\MSVC" -Directory -ErrorAction SilentlyContinue

		foreach ($msvcPath in $msvcPaths) {
			$versions = Get-ChildItem -Path $msvcPath.FullName -Directory | Where-Object { $_.Name -match '^\d+\.\d+\.\d+' }

			foreach ($version in $versions) {
				$availableVersions += $version.Name.Substring(0, 5)
			}
		}
	}
}

$availableVersions = $availableVersions | Select-Object -Unique | Sort-Object

if ($availableVersions.Count -eq 0) {
	Write-Host "No MSVC versions found!" -ForegroundColor Red
	exit 1
}

Write-Host "Found $($availableVersions.Count) unique MSVC version(s)`n" -ForegroundColor Green

$results = @()

foreach ($version in $availableVersions) {
	Write-Host "`n========================================" -ForegroundColor Yellow
	Write-Host "  Testing MSVC $version" -ForegroundColor Yellow
	Write-Host "========================================" -ForegroundColor Yellow

	& $scriptPath -MSVCVersion $version -BuildType $BuildType

	$result = [PSCustomObject]@{
		Version = $version
		Success = ($LASTEXITCODE -eq 0)
	}

	$results += $result

	Start-Sleep -Seconds 1
}

# Summary
Write-Host "`n`n========================================" -ForegroundColor Cyan
Write-Host "            BUILD SUMMARY" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$successCount = ($results | Where-Object { $_.Success }).Count
$failCount = ($results | Where-Object { -not $_.Success }).Count

foreach ($result in $results) {
	$status = if ($result.Success) { "SUCCESS" } else { "FAILED" }
	$color = if ($result.Success) { "Green" } else { "Red" }

	Write-Host "  MSVC $($result.Version): " -NoNewline
	Write-Host $status -ForegroundColor $color
}

Write-Host "`n----------------------------------------" -ForegroundColor Cyan
Write-Host "  Total: $($results.Count) | Success: $successCount | Failed: $failCount" -ForegroundColor Cyan
Write-Host "----------------------------------------`n" -ForegroundColor Cyan

if ($failCount -gt 0) {
	exit 1
} else {
	exit 0
}
