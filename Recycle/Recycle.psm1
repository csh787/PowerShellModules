#Set-StrictMode -Version Latest

function Remove-ItemSafely {

    [CmdletBinding(DefaultParameterSetName='Path', SupportsShouldProcess=$true, ConfirmImpact='Medium', SupportsTransactions=$true, HelpUri='http://go.microsoft.com/fwlink/?LinkID=113373')]
    param(
        [Parameter(ParameterSetName='Path', Mandatory=$true, Position=0, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [string[]]
        ${Path},

        [Parameter(ParameterSetName='LiteralPath', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias('PSPath')]
        [string[]]
        ${LiteralPath},

        [string]
        ${Filter},

        [string[]]
        ${Include},

        [string[]]
        ${Exclude},

        [switch]
        ${Recurse},

        [switch]
        ${Force},

        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [pscredential]
        [System.Management.Automation.CredentialAttribute()]
        ${Credential},
    
        [switch]
        $DeletePermanently)


    begin
    {
        try {
            $outBuffer = $null
            if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
            {
                $PSBoundParameters['OutBuffer'] = 1
            }
            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Management\Remove-Item', [System.Management.Automation.CommandTypes]::Cmdlet)
            if ($PSBoundParameters['DeletePermanently'] -or $PSBoundParameters['LiteralPath'] -or $PSBoundParameters['Filter'] -or $PSBoundParameters['Include'] -or $PSBoundParameters['Exclude'] -or $PSBoundParameters['Recurse'] -or $PSBoundParameters['Force'] -or $PSBoundParameters['Credential']) {
                if ($PSBoundParameters['DeletePermanently']) { $PSBoundParameters.Remove('DeletePermanently') | Out-Null }
                $scriptCmd = {& $wrappedCmd @PSBoundParameters }
            } else {
                $scriptCmd = {& Recycle-Item -Path $PSBoundParameters['Path'] }
            }

            $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
            $steppablePipeline.Begin($PSCmdlet)
        } catch {
            throw
        }
    }

    process
    {
        try {
            $steppablePipeline.Process($_)
        } catch {
            throw
        }
    }

    end
    {
        try {
            $steppablePipeline.End()
        } catch {
            throw
        }
    }
<#

.ForwardHelpTargetName Microsoft.PowerShell.Management\Remove-Item
.ForwardHelpCategory Cmdlet

#>

}

function Recycle-Item($Path) {
    $item = Get-Item $Path
    $directoryPath = Split-Path $item -Parent
    
    $shell = new-object -comobject "Shell.Application"
    $shellFolder = $shell.Namespace($directoryPath)
    $shellItem = $shellFolder.ParseName($item.Name)
    $shellItem.InvokeVerb("delete")
}


Export-ModuleMember -Function Remove-ItemSafely