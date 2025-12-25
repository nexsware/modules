# Script to fetch PostgreSQL database connection info from Linode
# Usage: .\get-db-info.ps1 -Token "YOUR_LINODE_TOKEN"

param(
    [Parameter(Mandatory=$true)]
    [string]$Token
)

Write-Host "Fetching PostgreSQL databases from Linode..." -ForegroundColor Cyan

$headers = @{
    "Authorization" = "Bearer $Token"
    "Content-Type" = "application/json"
}

try {
    $response = Invoke-RestMethod -Uri "https://api.linode.com/v4/databases/postgresql/instances" -Headers $headers -Method Get

    Write-Host "`nFound $($response.results) PostgreSQL database(s):`n" -ForegroundColor Green

    foreach ($db in $response.data) {
        Write-Host "================================" -ForegroundColor Yellow
        Write-Host "Database: $($db.label)" -ForegroundColor White
        Write-Host "================================" -ForegroundColor Yellow
        Write-Host "ID:               $($db.id)"
        Write-Host "Status:           $($db.status)"
        Write-Host "Engine:           $($db.engine)"
        Write-Host "Region:           $($db.region)"
        Write-Host "Type:             $($db.type)"
        Write-Host ""
        Write-Host "PRIMARY HOST:     $($db.hosts.primary)" -ForegroundColor Cyan
        Write-Host "PORT:             $($db.port)" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Root Username:    $($db.root_username)"
        Write-Host "SSL Required:     $($db.ssl_connection)"
        Write-Host ""
        Write-Host "PuTTY Tunnel Destination:" -ForegroundColor Green
        Write-Host "  $($db.hosts.primary):$($db.port)" -ForegroundColor White
        Write-Host ""
        Write-Host "Allow List IPs:" -ForegroundColor Yellow
        $db.allow_list | ForEach-Object { Write-Host "  - $_" }
        Write-Host "`n"
    }

    Write-Host "================================" -ForegroundColor Yellow
    Write-Host "`nTo create SSH tunnel in PuTTY:" -ForegroundColor Cyan
    Write-Host "1. Source port: 5432"
    Write-Host "2. Destination: <PRIMARY_HOST>:<PORT> (shown above)"
    Write-Host "3. Connect to: 23.92.20.65 (your Linode instance)"
    Write-Host "`n"

} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Please check your API token." -ForegroundColor Red
}
