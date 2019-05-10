function Get-SnowLink {
    <#
    .SYNOPSIS
    Generates a URL searching for the specified term
    .PARAMETER Search Term
    The term for which to search
    .EXAMPLE
    !Get-Quicklink RITM1234567
    .EXAMPLE
    !sn CIO1234567
    #>

    [PoshBot.BotCommand(
    Aliases = ('sn'),
    KeepHistory = $false
    )]
    [cmdletbinding()]
    param(
    [PoshBot.FromConfig('TicketingPath')]
    [parameter(Mandatory)]
    [string]$TicketingPath,
    [string]$SearchTerm
    )
    $returnstatement = $TicketingPath + $SearchTerm
    Write-Output "Sure thing, here you go! [$SearchTerm]($returnstatement)"
}

function Get-QuickLink {
    <#
    .SYNOPSIS
    Searches for a shortened URL for the specified keyword
    .PARAMETER Search Term
    The term for which to search in the link repository
    .EXAMPLE
    !linkme blah
    #>

    [PoshBot.BotCommand(
        Aliases = ('linkme'),
        KeepHistory = $false
    )]
    [cmdletbinding()]
    param(
    [PoshBot.FromConfig('DBPath')]
    [parameter(Mandatory)]
    [string]$DBPath,
    [string]$SearchTerm,
    [switch]$full
    )
    $returnstatement = @()
    if (Test-Path $DBPath) {
        $hash = Get-Content -Path $DBPath -Raw | ConvertFrom-Metadata
        foreach($key in $hash.keys) {
            if ($hash[$key].keywords.Contains($SearchTerm)) {
                if ($full) {
                    $returnstatement += "[$SearchTerm]($hash[$key].fullurl)"
                }else {
                    $returnstatement += "[$SearchTerm]($hash[$key].shortlink)"
                }
            }
        }
    }
    if ($returnstatement = "") {
        Write-Output "Sorry, I coudln't find anything for $SearchTerm. :("
    } else {
        Write-Output "Here's what I found: $returnstatement"
    }
}

function New-QuickLink {
    <#
    .SYNOPSIS
    Adds a new quicklink
    .PARAMETER Name
    name of the resource
    .PARAMETER shortlink
    the url path for this resource
    .PARAMETER full
    the full link for this resource
    .PARAMETER keywords
    A number of keywords related to this
    .EXAMPLE
    !New-QuickLink blah
    .EXAMPLE
    !New-QuickLink IDX -shortlink blah -full "https://blah.com" -keywords blah, blah
    .EXAMPLE
    !newlink blah
    #>

    [PoshBot.BotCommand(
        Aliases = ('newlink')
    )]
    [cmdletbinding()]
    param(
        [PoshBot.FromConfig('DBPath')]
        [parameter(Mandatory)]
        [string]$DBPath,
        [PoshBot.FromConfig('Shortlink')]
        [parameter(Mandatory)]
        [string]$shortlink,
        [Parameter(Position=0, Mandatory=$true)]
        [string]$Name,
        [string]$shortpath,
        [string]$fullurl,
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$keywords
    )

    if (Test-Path $DBPath) {
        $hash = Get-Content -Path $DBPath -Raw | ConvertFrom-Metadata
        foreach($key in $hash.keys) {
            if ($key.equals($Name.ToLower())) {
                Write-Output "Link Already Exists!"
                return
            }
        }

        $hash.add($Name.ToLower(), 
            @{
                short="$shortlink/$shortpath" 
                fullurl=$fullurl
                keywords=$keywords 
            }
        )
        $meta = $hash | ConvertTo-Metadata
        if (-not (Test-Path -Path $dbpath)) {
            New-Item -Path $dbpath -ItemType File
        }
        $meta | Out-file -FilePath $dbpath -Force -Encoding utf8
        Write-Output "Created entry for $Name."
                
    }
}
