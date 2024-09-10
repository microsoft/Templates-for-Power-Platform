<#
.SYNOPSIS
    Tests network connection to a specified host and port.
.DESCRIPTION
    This script attempts to establish a TCP connection to the specified host and port,
    and reports the result in a JSON format.
.PARAMETER HostName
    The hostname or IP address to connect to.
.PARAMETER Port
    The port number to connect to.
#>
param (
   [Parameter(Mandatory=$true)]
   [string]$hostName,

   [Parameter(Mandatory=$true)]
   [string]$port
)

$job = Start-Job -ScriptBlock {
    param($hostName, $port)
    Test-NetConnection -ComputerName $hostName -Port $port
} -ArgumentList $hostName, $port

if (Wait-Job -Job $job -Timeout 15) {
    $result = Receive-Job -Job $job

    if ($result.TcpTestSucceeded) {
        Write-Host -NoNewLine "[{'step': 'CheckNetworkConnection', 'status': 'Success', 'message': 'Successfully connected to $hostName over port $port.'}]"
    }
    else {
         Write-Host -NoNewLine "[{'step': 'CheckNetworkConnection', 'status': 'Error', 'message': 'Failed to connect to $hostName over port $port.'}]"
    }
}
else {
    Write-Host -NoNewLine "[{'step': 'CheckNetworkConnection', 'status': 'Error', 'message': 'The connection to $hostName over port $port timed out after 15 seconds.'}]"
}

Remove-Job -Force -Job $job