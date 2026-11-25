$ErrorActionPreference='Stop'
$root=Split-Path $PSScriptRoot -Parent
$wrapper=Join-Path $PSScriptRoot 'moon.ps1'
Push-Location ([IO.Path]::GetTempPath())
try {
  $before=(Get-Location).Path
  $output='{"members":[{"id":"a","left_weight":1,"right_weight":1}],"left_threshold":1,"right_threshold":1}' | & $wrapper run cmd/main --target js -- -
  if ($LASTEXITCODE -ne 0 -or ($output | ConvertFrom-Json).status -ne 'intersecting') { throw 'Pipeline failed' }
  if ((Get-Location).Path -ne $before) { throw 'Directory restoration failed' }
  foreach ($scenario in @('read-write','rollout','maintenance')) {
    $output=& $wrapper run cmd/main --target js -- (Join-Path $root "examples/$scenario.json")
    if ($LASTEXITCODE -ne 0) { throw "Scenario failed: $scenario" }
    $expected=if ($scenario -ne 'read-write') {'disjoint'} else {'intersecting'}
    if (($output | ConvertFrom-Json).status -ne $expected) { throw 'Unexpected scenario result' }
  }
  foreach ($scenario in @('migration-ready','migration-bridge','migration-outage')) {
    $output=& $wrapper run cmd/main --target js -- --migration (Join-Path $root "examples/$scenario.json")
    if ($LASTEXITCODE -ne 0) { throw "Migration scenario failed: $scenario" }
    $expected=if ($scenario -eq 'migration-ready') {'ready'} else {'blocked'}
    if (($output | ConvertFrom-Json).status -ne $expected) { throw "Unexpected migration result: $scenario" }
  }

  $domainPath=Join-Path $root 'examples/resilience-balanced.json'
  $result=Get-Content -LiteralPath $domainPath -Raw | & $wrapper run cmd/main --target js -- --resilience -
  if ($LASTEXITCODE -ne 0 -or ($result | ConvertFrom-Json).policies[0].worst_remaining -ne 3) {
    throw 'Failure-domain stdin check failed'
  }
} finally { Pop-Location }
Write-Host 'PASS PowerShell pipeline, migration and failure-domain scenarios'
