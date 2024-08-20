param (
   [string]$hostName,
   [string]$port
)

$job = Start-Job -ScriptBlock {
    param($hostName, $port)
    Test-NetConnection -ComputerName $hostName -Port $port
} -ArgumentList $hostName, $port

for ($i = 0; $i -lt 5; $i++) {
    Start-Sleep -Seconds 1
}

if (Wait-Job -Job $job -Timeout 5) {
    $result = Receive-Job -Job $job

    if ($result.TcpTestSucceeded) {
        Write-Host -NoNewLine "[{'step': 'CheckNetworkConnection', 'status': 'Success', 'message': 'Successfully connected to %hostName% over port %port%.'}]"
    }
    else {
         Write-Host -NoNewLine "[{'step': 'CheckNetworkConnection', 'status': 'Error', 'message': 'Failed to connect to %hostName% over port %port%.'}]"
    }
}
else {
    Write-Host -NoNewLine "[{'step': 'CheckNetworkConnection', 'status': 'Error', 'message': 'The connection to %hostName% over port %port% timed out after 5 seconds.'}]"
}

Remove-Job -Force -Job $job