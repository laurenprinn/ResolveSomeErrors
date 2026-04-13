# Compare builds across all available MSVC toolsets
# This script builds with v140, v141, v142, and v143 and compares results

param(
	[string]$BuildType = "Debug",
	[string]$CppStandard = "14"
)

Write-Host "=============================================" -ForegroundColor Magenta
Write-Host "  Multi-Toolset Build Comparison" -ForegroundColor Magenta
Write-Host "=============================================" -ForegroundColor Magenta
Write-Host "C++ Standard: C++$CppStandard" -ForegroundColor White
Write-Host "Build Type:   $BuildType" -ForegroundColor White
Write-Host ""

$toolsets = @("v140", "v141", "v142", "v143")
$results = @()

foreach ($toolset in $toolsets) {
	Write-Host "=============================================" -ForegroundColor Cyan
	Write-Host "Building with $toolset..." -ForegroundColor Cyan
	Write-Host "=============================================" -ForegroundColor Cyan

	$result = @{
		Toolset = $toolset
		Success = $false
		BuildTime = 0
		ExePath = ""
		Error = ""
	}

	try {
		$startTime = Get-Date

		# Run the build script silently and capture output
		$output = & .\build-with-toolset.ps1 -Toolset $toolset -CppStandard $CppStandard -BuildType $BuildType 2>&1 | Out-String

		$endTime = Get-Date
		$result.BuildTime = ($endTime - $startTime).TotalSeconds

		if ($LASTEXITCODE -eq 0) {
			$result.Success = $true
			$result.ExePath = "build-$toolset-cpp$CppStandard\ResolveSomeErrors\$BuildType\ResolveSomeErrors.exe"
			Write-Host "✓ SUCCESS in $([math]::Round($result.BuildTime, 2))s" -ForegroundColor Green
		} else {
			$result.Error = "Build failed with exit code $LASTEXITCODE"
			Write-Host "✗ FAILED" -ForegroundColor Red
		}
	}
	catch {
		$result.Error = $_.Exception.Message
		Write-Host "✗ ERROR: $($_.Exception.Message)" -ForegroundColor Red
	}

	$results += $result
	Write-Host ""
}

# Summary Table
Write-Host "=============================================" -ForegroundColor Magenta
Write-Host "  Build Summary" -ForegroundColor Magenta
Write-Host "=============================================" -ForegroundColor Magenta
Write-Host ""

$table = @"
Toolset  | Version    | Status  | Time (s) | Notes
---------|------------|---------|----------|------------------
"@

$toolsetNames = @{
	"v140" = "VS 2015   "
	"v141" = "VS 2017   "
	"v142" = "VS 2019   "
	"v143" = "VS 2022   "
}

foreach ($result in $results) {
	$status = if ($result.Success) { "✓ PASS " } else { "✗ FAIL " }
	$time = if ($result.Success) { [math]::Round($result.BuildTime, 2).ToString().PadLeft(8) } else { "   -    " }
	$notes = if ($result.Success) { "OK" } else { $result.Error.Substring(0, [Math]::Min(15, $result.Error.Length)) }

	$table += "`nv$($result.Toolset.Substring(1)) | $($toolsetNames[$result.Toolset]) | $status | $time | $notes"
}

Write-Host $table
Write-Host ""

# Count successes and failures
$successCount = ($results | Where-Object { $_.Success }).Count
$totalCount = $results.Count

if ($successCount -eq $totalCount) {
	Write-Host "✓ All $totalCount toolset(s) built successfully!" -ForegroundColor Green
} elseif ($successCount -gt 0) {
	Write-Host "⚠ $successCount of $totalCount toolset(s) built successfully" -ForegroundColor Yellow
} else {
	Write-Host "✗ All builds failed" -ForegroundColor Red
}

Write-Host ""

# Detailed Results
if ($successCount -gt 0) {
	Write-Host "Successful Builds:" -ForegroundColor Green
	foreach ($result in $results | Where-Object { $_.Success }) {
		Write-Host "  [$($result.Toolset)] $($result.ExePath)" -ForegroundColor Gray
	}
	Write-Host ""
}

if ($successCount -lt $totalCount) {
	Write-Host "Failed Builds:" -ForegroundColor Red
	foreach ($result in $results | Where-Object { -not $_.Success }) {
		Write-Host "  [$($result.Toolset)] $($result.Error)" -ForegroundColor Gray
	}
	Write-Host ""
}

# Option to run all successful builds
if ($successCount -gt 0) {
	$runChoice = Read-Host "Run all successful builds to verify? (y/n)"
	if ($runChoice -eq 'y') {
		Write-Host ""
		foreach ($result in $results | Where-Object { $_.Success }) {
			Write-Host "=============================================" -ForegroundColor Cyan
			Write-Host "Running $($result.Toolset) build..." -ForegroundColor Cyan
			Write-Host "=============================================" -ForegroundColor Cyan

			if (Test-Path $result.ExePath) {
				& ".\$($result.ExePath)"
			} else {
				Write-Host "Executable not found: $($result.ExePath)" -ForegroundColor Red
			}
			Write-Host ""
		}
	}
}

Write-Host "Comparison complete!" -ForegroundColor Magenta
