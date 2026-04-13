# Build script to demonstrate modern MSVC conformance errors
# Run this to see C52xx and C53xx warnings/errors

param(
	[switch]$TreatWarningsAsErrors = $false
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Build Modern Error Demonstrations" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$buildDir = "build-modern-errors"

# Clean previous build
if (Test-Path $buildDir) {
	Write-Host "Cleaning previous build..." -ForegroundColor Yellow
	Remove-Item $buildDir -Recurse -Force
}

# Create build directory
New-Item -ItemType Directory -Path $buildDir -Force | Out-Null

# Copy the CMakeLists.txt for testing
Copy-Item "ResolveSomeErrors\TestModernErrors_CMakeLists.txt" "$buildDir\CMakeLists.txt"
Copy-Item "ResolveSomeErrors\TriggerModernErrorsACTUAL.cpp" "$buildDir\"

# Configure
Write-Host "Configuring CMake..." -ForegroundColor Green
Push-Location $buildDir

cmake -G "Visual Studio 17 2022" -A x64 .

if ($LASTEXITCODE -ne 0) {
	Write-Host "CMake configuration failed!" -ForegroundColor Red
	Pop-Location
	exit $LASTEXITCODE
}

# Build
Write-Host "`nBuilding with /W4 and /permissive-..." -ForegroundColor Green
Write-Host "(You should see warnings C5286, C5292, C5294, C5295)" -ForegroundColor Yellow
Write-Host ""

cmake --build . --config Debug 2>&1 | Tee-Object -Variable buildOutput

Pop-Location

# Analyze output
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Build Analysis" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$warnings = @{
	"C5286" = @{ Found = $false; Description = "Different enum comparison" }
	"C5292" = @{ Found = $false; Description = "Enum > float operation" }
	"C5294" = @{ Found = $false; Description = "Float < enum operation" }
	"C5295" = @{ Found = $false; Description = "Array too small" }
}

foreach ($line in $buildOutput) {
	foreach ($code in $warnings.Keys) {
		if ($line -match $code) {
			$warnings[$code].Found = $true
		}
	}
}

Write-Host "`nWarnings Detected:" -ForegroundColor White
foreach ($code in $warnings.Keys | Sort-Object) {
	$status = if ($warnings[$code].Found) { "✓ FOUND" } else { "✗ NOT FOUND" }
	$color = if ($warnings[$code].Found) { "Green" } else { "Red" }
	$desc = $warnings[$code].Description

	Write-Host "  [$code] $status - $desc" -ForegroundColor $color
}

Write-Host ""

if ($warnings.Values | Where-Object { $_.Found }) {
	Write-Host "Success! Modern conformance warnings are visible." -ForegroundColor Green
	Write-Host "These warnings help catch potential bugs." -ForegroundColor Green
} else {
	Write-Host "No warnings found. This might mean:" -ForegroundColor Yellow
	Write-Host "  - Warning level is too low" -ForegroundColor Yellow
	Write-Host "  - /permissive- not enabled" -ForegroundColor Yellow
	Write-Host "  - Warnings are suppressed" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Build log saved to console output above." -ForegroundColor Cyan
