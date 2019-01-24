# 
# FIRST, you have to get jq from
#
# https://stedolan.github.io/jq/download/
#
#
# If you have trouble visit
#
# https://woshub.com/port-forwarding-in-windows/
#
# and analyze the prerequisites 
#
# --------------------------------------------------------------------------------------------------------------------------------------------------------

$mysql_host_port_generated_by_ddev = ddev describe -j | jq -r .raw.dbinfo.published_port
$mysql_host_port_wanted = "3306"

if ($mysql_host_port_generated_by_ddev -eq "null")
{
    Write-Host -ForegroundColor Red ("Database Port not found.")
    ddev describe
}
else
{
    Write-Host -ForegroundColor Green  ("MySql Host Port wurde von ddev festgelegt auf: " + $mysql_host_port_generated_by_ddev)
    Write-Host ("Versuche diesen auf $mysql_host_port_wanted weiterzuleiten.")

    netsh interface portproxy reset
    netsh interface portproxy add v4tov4 listenport=3306 listenaddress=127.0.0.1 connectport=$mysql_host_port_generated_by_ddev connectaddress=127.0.0.1
    
    $test = netstat -ano | findstr :$mysql_host_port_wanted
    
    if ([string]::IsNullOrEmpty($test))
    {
        Write-Host -BackgroundColor Red ("Hat nicht geklappt.")
    }
    else
    {
        Write-Host($test)
    }
}

