# Build script for VS 2017 (v141) toolset with compatible Windows SDK
# 
# The v141 toolset should work with SDK 10.0.22621.0 or 10.0.26100.0

param(
	[string]$BuildType = "Debug",
	[string]$SdkVersion = "10.0.22621.0"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Building with VS 2017 (v141) Toolset" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "SDK Version: $SdkVersion" -ForegroundColor Yellow
Write-Host "Build Type: $BuildType" -ForegroundColor Yellow
Write-Host ""

# Clean previous build
$buildDir = "build-v141-cpp14"
if (Test-Path $buildDir) {
	Write-Host "Cleaning previous build..." -ForegroundColor Yellow
	Remove-Item $buildDir -Recurse -Force -ErrorAction SilentlyContinue
}

# Configure CMake with v141 toolset and C++14
Write-Host "Configuring CMake..." -ForegroundColor Green
cmake -G "Visual Studio 17 2022" `
	  -T v141 `
	  -A x64 `
	  -DCMAKE_CXX_STANDARD=14 `
	  -B $buildDir

if ($LASTEXITCODE -ne 0) {
	Write-Host "CMake configuration failed!" -ForegroundColor Red
	exit $LASTEXITCODE
}

# Patch vcxproj to use compatible SDK
Write-Host "`nPatching project files for SDK $SdkVersion..." -ForegroundColor Green
Get-ChildItem -Path $buildDir -Filter "*.vcxproj" -Recurse | ForEach-Object {
	$content = Get-Content $_.FullName -Raw
	$content = $content -replace '<WindowsTargetPlatformVersion>.*?</WindowsTargetPlatformVersion>', 
								  "<WindowsTargetPlatformVersion>$SdkVersion</WindowsTargetPlatformVersion>"
	Set-Content -Path $_.FullName -Value $content
	Write-Host "  Patched: $($_.Name)" -ForegroundColor Gray
}

# Build
Write-Host "`nBuilding project..." -ForegroundColor Green
cmake --build $buildDir --config $BuildType

if ($LASTEXITCODE -eq 0) {
	Write-Host "`n========================================" -ForegroundColor Green
	Write-Host "Build successful!" -ForegroundColor Green
	Write-Host "========================================" -ForegroundColor Green
	Write-Host "Executable: $buildDir\ResolveSomeErrors\$BuildType\ResolveSomeErrors.exe" -ForegroundColor Cyan

	# Optionally run it
	$runChoice = Read-Host "`nRun the executable? (y/n)"
	if ($runChoice -eq 'y') {
		& ".\$buildDir\ResolveSomeErrors\$BuildType\ResolveSomeErrors.exe"
	}
} else {
	Write-Host "`n========================================" -ForegroundColor Red
	Write-Host "Build failed!" -ForegroundColor Red
	Write-Host "========================================" -ForegroundColor Red
	exit $LASTEXITCODE
}
