<#
.Synopsis
Short description
.DESCRIPTION
Long description
.EXAMPLE
Example of how to use this cmdlet
.EXAMPLE
Another example of how to use this cmdlet
#>
function Get-AzVMNetworkInMetric
{
    [CmdletBinding()]
    [Alias()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [string]
        $ResourceGroupName,

        # Param2 help description
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1)]
        [string]
        $Name
    )

    Begin
    {
    }
    Process
    {
        try
        {
            $vm = get-azvm -ResourceGroupName $ResourceGroupName -Name $Name -ErrorAction 'Stop'
        }
        catch
        {
            throw $_
        }
        
        try
        {
            $vmStatus = get-azvm -ResourceGroupName $ResourceGroupName -Name $Name -status -ErrorAction 'Stop'
        }
        catch
        {
            throw $_
        }

        $NetInTotalMetrics = get-azMetric -ResourceId $vm.Id -StartTime ([datetime]::now.AddDays(-1)) -TimeGrain (New-TimeSpan -minutes 15 ) -metricName 'Network In Total' 

        Write-host "Status:  $($vmStatus.statuses |? {$_.code -like "PowerState*"} | % displayStatus)"
        Write-host "Minimum: $([math]::round($($NetInTotalMetrics.Data.Average | Measure-Object -Minimum | % Minimum),2))"
        Write-host "Maximum: $([math]::round($($NetInTotalMetrics.Data.Average | Measure-Object -Maximum | % Maximum),2))"
        Write-host "Average: $([math]::round($($NetInTotalMetrics.Data.Average | Measure-Object -Average | % Average),2))"

        show-graph -datapoints ($NetInTotalMetrics.data | % average) -XAxisTitle "$Name - 24 hours" -YAxisTitle "Network In Total"
    }
    End
    {
    }
}