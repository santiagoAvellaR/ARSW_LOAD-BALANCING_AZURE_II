$jobs = @()
$logDir = ".\logs"
if (!(Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir | Out-Null
}

$workingDir = $PSScriptRoot  # Directorio donde está el script
$startTime = Get-Date

for ($i=0; $i -lt 10; $i++) {
    $logFile = "$logDir\run_$i.log"
    $jobs += Start-Job -ScriptBlock {
        param($logFile, $workingDir)
        Set-Location $workingDir
        newman run .\ARSW_LOAD-BALANCING_AZURE.postman_collection.json -e .\ARSW_LOAD-BALANCING_AZURE.postman_environment.json --reporter-cli-no-ansi | Tee-Object -FilePath $logFile
    } -ArgumentList $logFile, $workingDir
}

Write-Host "Esperando a que terminen todos los jobs..."
$jobs | Wait-Job

$totalJobs = $jobs.Count
$success = 0
$fail = 0
$totalDuration = 0

for ($i=0; $i -lt $totalJobs; $i++) {
    $logFile = "$logDir\run_$i.log"
    $logContent = Get-Content $logFile -Raw

    # Buscar si la prueba fue exitosa
    if ($logContent -match "\[200 OK") {
        $success++
        $status = "EXITO"
    } else {
        $fail++
        $status = "ERROR"
    }

    # Extraer duración de la prueba (ejemplo: total run duration: 1677ms)
    if ($logContent -match "total run duration: (\d+)ms") {
        $duration = [int]$matches[1]
        $totalDuration += $duration
    } else {
        $duration = "N/A"
    }

    Write-Host "Job ${i}: $status - Duracion: $duration ms"
}

$endTime = Get-Date
$elapsed = ($endTime - $startTime).TotalMilliseconds

Write-Host "---------------------------------------------"
Write-Host "Total de pruebas exitosas: $success"
Write-Host "Total de pruebas con error: $fail"
Write-Host "Tiempo total sumado de todas las pruebas: $totalDuration ms"
Write-Host "Tiempo real transcurrido: $([math]::Round($elapsed)) ms"