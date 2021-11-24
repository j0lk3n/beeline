$username = 'username'
$filepath = 'c:\scripts\RdpLogoff\servers.txt'

If (!(Get-module PSTerminalServices )) 
{
    try 
    {
        Import-Module PSTerminalServices
        Write-Host "PSTerminalServices Module Loaded" -ForegroundColor Green
    } 
    catch 
    {
        Write-Host "PSTerminalServices module does not exist, please install" -ForegroundColor Red
    }
}

foreach ($server in (Get-Content -Path $filepath)) 
{
    Write-Host "Checking for $username on $server" -ForegroundColor Cyan   
    try 
    {
        $loggedInUsers = get-tssession -ComputerName $server
        if ($loggedInUsers.UserName -contains $username) 
        {

            Write-Host "Found $username connected to $server" -ForegroundColor Green
            $userNameSessionID = $loggedInUsers | Where-Object -Property UserName -eq $username | Select-Object -Property SessionID
            foreach ($sessionID in $userNameSessionID) 
            {
                $currentSessionID = $sessionID.SessionId       
                Write-Host "$username's SessionID is $currentSessionID" -ForegroundColor Cyan
                try 
                {
                    Start-Sleep 2
                    Stop-TSSession -ComputerName $server -Id $currentSessionID -Confirm:$false -Force
                    Write-Host "Disconnected $username's session $currentSessionID from $server" -ForegroundColor Green
                }
                catch 
                {
                    Write-Host "Unable to disconnect $username's session $currentSesionID from $server" -ForegroundColor Red
                }
            }
        }
        else 
        {
            Write-Host "User $username not connected to $server" -ForegroundColor Yellow
        }
    }
    catch 
    {
        Write-Host "Unable to connect to $server" -ForegroundColor Red
    }
}
