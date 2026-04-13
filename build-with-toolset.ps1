# Generic build script for different MSVC toolsets with SDK compatibility
# 
# Usage:
#   .\build-with-toolset.ps1 -Toolset v140    # VS 2015
#   .\build-with-toolset.ps1 -Toolset v141    # VS 2017
#   .\build-with-toolset.ps1 -Toolset v142    # VS 2019
#   .\build-with-toolset.ps1 -Toolset v143    # VS 2022

param(
	[Parameter(Mandatory=$true)]
	[ValidateSet("v140", "v141", "v142", "v143", "v145")]
	[string]$Toolset,

	[string]$BuildType = "Debug",

	[ValidateSet("11", "14", "17", "20")]
	[string]$CppStandard = "14",

	[string]$SdkVersion = ""
)

# Toolset information
$toolsetInfo = @{
	"v140" = @{
		Name = "Visual Studio 2015"
		Year = "2015"
		DefaultSdk = "10.0.22621.0"
		Color = "Yellow"
	}
	"v141" = @{
		Name = "Visual Studio 2017"
		Year = "2017"
		DefaultSdk = "10.0.22621.0"
		Color = "Cyan"
	}
	"v142" = @{
		Name = "Visual Studio 2019"
		Year = "2019"
		DefaultSdk = "10.0.26100.0"
		Color = "Green"
	}
	"v143" = @{
		Name = "Visual Studio 2022"
		Year = "2022"
		DefaultSdk = "10.0.26100.0"
		Color = "Magenta"
	}
	"v145" = @{
		Name = "Visual Studio 2026"
		Year = "2026"
		DefaultSdk = "10.0.26100.0"
		Color = "Magenta"
	}
}

$info = $toolsetInfo[$Toolset]
$color = $info.Color

# Use default SDK if not specified
if ([string]::IsNullOrEmpty($SdkVersion)) {
	$SdkVersion = $info.DefaultSdk
}

# Override C++ standard for v145 to use C++20
if ($Toolset -eq "v145" -and $CppStandard -eq "14") {
	$CppStandard = "20"
	Write-Host "Note: Overriding C++ standard to C++20 for v145 toolset" -ForegroundColor Yellow
}

Write-Host "========================================" -ForegroundColor $color
Write-Host "Building with $($info.Name) ($Toolset)" -ForegroundColor $color
Write-Host "========================================" -ForegroundColor $color
Write-Host "Toolset:      $Toolset" -ForegroundColor White
Write-Host "C++ Standard: C++$CppStandard" -ForegroundColor White
Write-Host "SDK Version:  $SdkVersion" -ForegroundColor White
Write-Host "Build Type:   $BuildType" -ForegroundColor White
Write-Host ""

# Build directory name
$buildDir = "build-$Toolset-cpp$CppStandard"

# Clean previous build
if (Test-Path $buildDir) {
	Write-Host "Cleaning previous build directory..." -ForegroundColor Yellow
	Remove-Item $buildDir -Recurse -Force -ErrorAction SilentlyContinue
	Start-Sleep -Milliseconds 500
}

# Configure CMake
Write-Host "Configuring CMake..." -ForegroundColor Green
$cmakeArgs = @(
	"-G", "Visual Studio 17 2022",
	"-T", $Toolset,
	"-A", "x64",
	"-DCMAKE_CXX_STANDARD=$CppStandard",
	"-B", $buildDir
)

& cmake @cmakeArgs

if ($LASTEXITCODE -ne 0) {
	Write-Host "`nCMake configuration failed!" -ForegroundColor Red
	exit $LASTEXITCODE
}

# Patch vcxproj files to use specified SDK
Write-Host "`nPatching project files for SDK $SdkVersion..." -ForegroundColor Green
$patchCount = 0
Get-ChildItem -Path $buildDir -Filter "*.vcxproj" -Recurse | ForEach-Object {
	$content = Get-Content $_.FullName -Raw
	$originalContent = $content
	$content = $content -replace '<WindowsTargetPlatformVersion>.*?</WindowsTargetPlatformVersion>', 
								  "<WindowsTargetPlatformVersion>$SdkVersion</WindowsTargetPlatformVersion>"

	if ($content -ne $originalContent) {
		Set-Content -Path $_.FullName -Value $content
		Write-Host "  ✓ Patched: $($_.Name)" -ForegroundColor Gray
		$patchCount++
	}
}
Write-Host "  Patched $patchCount project file(s)" -ForegroundColor Gray

# Build
Write-Host "`nBuilding project..." -ForegroundColor Green
cmake --build $buildDir --config $BuildType

if ($LASTEXITCODE -eq 0) {
	Write-Host "`n========================================" -ForegroundColor $color
	Write-Host "✓ Build successful!" -ForegroundColor Green
	Write-Host "========================================" -ForegroundColor $color

	$exePath = "$buildDir\ResolveSomeErrors\$BuildType\ResolveSomeErrors.exe"
	Write-Host "`nExecutable: $exePath" -ForegroundColor Cyan

	# Show compiler version info
	Write-Host "`nBuild Info:" -ForegroundColor White
	Write-Host "  Toolset:  $($info.Name) ($Toolset)" -ForegroundColor Gray
	Write-Host "  Standard: C++$CppStandard" -ForegroundColor Gray
	Write-Host "  SDK:      $SdkVersion" -ForegroundColor Gray

	# Optionally run it
	Write-Host ""
	$runChoice = Read-Host "Run the executable? (y/n)"
	if ($runChoice -eq 'y') {
		Write-Host "`n--- Program Output ---" -ForegroundColor Cyan
		& ".\$exePath"
		Write-Host "--- End Output ---" -ForegroundColor Cyan
	}
} else {
	Write-Host "`n========================================" -ForegroundColor Red
	Write-Host "✗ Build failed!" -ForegroundColor Red
	Write-Host "========================================" -ForegroundColor Red
	Write-Host "Check the build log above for errors." -ForegroundColor Yellow
	exit $LASTEXITCODE
}
