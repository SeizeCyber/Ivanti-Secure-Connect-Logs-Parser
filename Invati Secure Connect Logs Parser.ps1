<#
.SYNOPSIS
    This PowerShell script parses Ivanti Secure Connect runtime logs (vc0) and converts them into a readable CSV format.

.DESCRIPTION
    This script provides a menu selection for choosing the type of vc0 log (Admin, Events, or Access). 
    It prompts the user to select a log file, processes the selected log file, replaces message codes with their descriptions, 
    and epoch timestamps with human-readable dates and eventually export to a structured csv format.

.PARAMETER <selection>
    Specifies the type of vc0 log to parse. Valid options are:
    1: Admin logs
    2: Events logs
    3: Access logs

.EXAMPLE
    .\Ivanti_Secure_Connect_Parser.ps1
    Prompts the user to select the type of vc0 log and the log file to process.

.NOTES
    Author: David Abrgel
    Version: 1.0.0
    Date Created: 09/02/2024
    Requirements: PowerShell 3.0 or above, Administrator mode and Ivanti Secure Connect runtime logs in vc0 format.

#>

# Define the Clean-LogFile function to remove non-printable characters excluding tabs, spaces, and end-of-line characters
function Clean-LogFile {
    param (
        [string]$InputFilePath,
        [string]$OutputFilePath
    )

    # Read the content of the input file
    $content = Get-Content -Path $InputFilePath -Raw

    # Define a regular expression pattern to match non-printable characters excluding tabs, spaces, and end-of-line characters
    $nonPrintablePattern = '[^\x09\x20-\x7E]'

    # Replace non-printable characters with an empty string
    $cleanedContent = $content -replace $nonPrintablePattern

    # Write the cleaned content to the output file
    $cleanedContent | Out-File -FilePath $OutputFilePath -Encoding utf8
}

# Menu selection for the type of vc0 log
Write-Host "                                                                                       "
Write-Host "                                                                                       "
Write-Host "                                #######################################################" 
Write-Host "                                #           Ivanti Secure Connect Logs Parser         #" 
Write-Host "                                #                                                     #" 
Write-Host "                                #       Converting Runtime Logs Into Readable CSV     #" 
Write-Host "                                #                                                     #" 
Write-Host "                                #                  Version: 1.0.0                     #" 
Write-Host "                                #                                                     #" 
Write-Host "                                #######################################################" 
Write-Host "                                                                                       "
Write-Host "                                Select the type of vc0 log:                            " -ForegroundColor Green
Write-Host "                                                                                       "
Write-Host "                                1. Admin                                               "
Write-Host "                                2. Events                                              "
Write-Host "                                3. Access                                              "
Write-Host "                                4. Split and clean vc0 file weighing over 2 MB         " -ForegroundColor Yellow
Write-Host "                                                                                       "
$selection = Read-Host "Enter your choice (1, 2, 3, or 4)"

# Validate the selection
if ($selection -notin '1', '2', '3', '4') {
    Write-Host "Invalid selection. Please choose 1, 2, 3, or 4."
    exit
}

# Prompt the user to select a file
$fileDialog = [System.Windows.Forms.OpenFileDialog]@{
    InitialDirectory = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Definition)
    Title = 'Select a log file'
}

# Validate the selection
if ($selection -notin '1', '2', '3', '4') {
    Write-Host "Invalid selection. Please choose 1, 2, 3, or 4."
    exit
}

# Prompt the user to select a file
$fileDialog = [System.Windows.Forms.OpenFileDialog]@{
    InitialDirectory = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Definition)
    Title = 'Select a log file'
}

# Define file filter based on the user's selection
switch ($selection) {
    '1' { $fileDialog.Filter = 'Admin logs (*.admin.vc0)|*.admin.vc0|All files (*.*)|*.*' }
    '2' { $fileDialog.Filter = 'Events logs (*.events.vc0)|*.events.vc0|All files (*.*)|*.*' }
    '3' { $fileDialog.Filter = 'Access logs (*.access.vc0)|*.access.vc0|All files (*.*)|*.*' }
    '4' { 
if ($selection -eq '4') {
    # Prompt the user to select a file
    $fileDialog = [System.Windows.Forms.OpenFileDialog]@{
        InitialDirectory = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Definition)
        Title = 'Select a log file'
    }

    $result = $fileDialog.ShowDialog()

    if ($result -eq 'OK') {
        $logFilePath = $fileDialog.FileName
        $outputDirectory = Join-Path -Path $PSScriptRoot -ChildPath "tmp_split_vc0"
        if (-not (Test-Path $outputDirectory)) {
            New-Item -Path $outputDirectory -ItemType Directory | Out-Null
        }
        $outputFilePath = Join-Path -Path $outputDirectory -ChildPath "cleaned_tmp.vc0"

        # Clean the selected log file
        Clean-LogFile -InputFilePath $logFilePath -OutputFilePath $outputFilePath

        $fileSize = (Get-Item $outputFilePath).Length / 1MB

        if ($fileSize -le 2) {
            Write-Host "The selected file is already under 2 MB. No need to split."
            $selection = '0'
        } else {
            # Calculate the number of parts needed
            $numParts = [math]::Ceiling($fileSize / 2)
            Write-Host "Splitting the file into $numParts parts..."

# Split the file into parts
for ($i = 0; $i -lt $numParts; $i++) {
    $start = $i * $partSize
    $end = [math]::Min(($i + 1) * $partSize, $fileContent.Length)
    $partContent = $fileContent.Substring($start, $end - $start)

    # Extract the original file name without extension
    $originalFileName = [System.IO.Path]::GetFileNameWithoutExtension($logFilePath)

    # Construct the part file name
    $partFileName = "part$($i + 1)_${originalFileName}.vc0"

    $partPath = Join-Path -Path $outputDirectory -ChildPath $partFileName
    $partContent | Out-File -FilePath $partPath -Encoding utf8
}

            Write-Host "File split completed. Parts saved in $outputDirectory"
        }
    } else {
        Write-Host "Operation canceled by the user."
        $selection = '0'
    }
    
    # Return to the menu
    return
}

    }
    default {
        Write-Host "Invalid selection. Please choose 1, 2, 3, or 4."
        exit
    }
}
$result = $fileDialog.ShowDialog()

if ($result -eq 'OK') {
    $logFilePath = $fileDialog.FileName

    # Read the content of the log file
    $logContent = Get-Content -Path $logFilePath -Raw

    # Define the regex pattern to identify the start of a line
    $startOfLinePattern = "((65a\w+\.\w+)|(65b\w+\.\w+))"

    # Use Select-String to find matches
    $matches = $logContent | ForEach-Object { $_ -split "`r`n" } | Select-String -Pattern $startOfLinePattern -AllMatches

    # Initialize variables for progress bar
    $totalMatches = $matches.Matches.Count
    $processedMatches = 0

    # Display initial progress bar
    Write-Progress -Activity "Processing Log File" -Status "Processing matches" -PercentComplete 0

    # Iterate through matches and replace the matches with a newline
    foreach ($match in $matches.Matches) {
        $logContent = $logContent -replace [regex]::Escape($match.Value), "`r`n$($match.Value)"

        # Update progress bar
        $processedMatches++
        $percentComplete = ($processedMatches / $totalMatches) * 100
        Write-Progress -Activity "Processing Log File" -Status "Processing matches" -PercentComplete $percentComplete
    }

    # Define the regex pattern for finding the epoch timestamp in the uid string
    $EpochRegexPattern = '_(17\d+)_'
    $startOfLineRegexPattern = '^((65a\w+\.\w+)|(65b\w+\.\w+))'

    # Initialize progress counter for the loop
    $processedLines = 0

    # Display initial progress bar for line processing
    Write-Progress -Activity "Processing Log File" -Status "Processing lines" -PercentComplete 0

    # Hashtable to map message codes to descriptions
    $messageCodeDescriptions = @{
        "WEB31809" = "Un-Official - Web API Request"
        "AUT24326" = "Log Auth Success"
        "AUT32051" = "Mode changed to SSL"
        "AUT23278" = "RealmRestrictionsPassed"
        "NWC30477" = "VPN Tunneling: User connected with transport mode."
        "NWC23465" = "VPN Tunneling: Session ended for user with IP"
        "NWC30993" = "UnOfficial Session Closed"
        "AGU30457" = "Starting dsagentd session."
        "NWC23464" = "VPN Tunneling: Session started for user with IP %1 and hostname %2"
        "NWC23508" = "KeyExchange"
        "NWC24328" = "Transport mode switched over to SSL for user"
        "AUT31829" = "Unknown authentication code"
        "AUT32033" = "Unknown authentication code - most likely LDAP related"
        "AUT24414" = "SOAP login succeeded"
        "AUT22673" = "Logout"
        "NWC32001" = "Unknown network code"
        "ERR24670" = "VPN Tunneling: ACL count = %1."
        "ERR31271" = "VPN Tunneling: Optimized ACL count"
        "AUT20914" = "Session Timeout"
        "EAM30446" = "ExtendSession"
        "EAM24460" = "Session resumed from user agent"
        "NWC32179" = "Unknown network code"
        "NWC32164" = "Unknown network code"
        "AUT20919" = "RemoteAddrChanged"
        "AUT31504" = "Agent-less login success"
        "USR31399" = "Unknown code for user change"
        "AUT23574" = "LogoutPrevSession"
        "USR31400" = "Unknown user code - most likely a TOTP related"
        "AUT31985" = "Failed Incorrect Token"
        "AGU30458" = "Ending dsagentd session."
        "AUT22886" = "User IdleTimeout"
        "NWC32185" = "Closing the connection as web sent handleEndConnection request"
        "AUT20915" = "UserIdleTimeoutByRequest"
        "AUT24327" = "LogAuthFailure"
        "ADM20599" = "LogCleared"
        "ADM32202" = "Unknown admin action"
        "ADM20664" = "Admin Idle Timeout"
        "ADM31931" = "Unknown admin action"
        "AUT30616" = "Admin Realm Restrictions Passed"
        "AUT30684" = "Admin Log Auth Success"
        "ADM20716" = "Added USA User"
        "ADM22668" = "Admin Login Success"
        "ADM31404" = "Unknown admin action - Most likely addition of MFA"
        "ADM22671" = "Admin Logout"
        "ADM22862" = "User Accounts modified. Removed username %1 from authentication server %2."
        "ADM31438" = "Unknown admin action"
        "ADM31317" = "Unknown admin action - Most likely upgrade action"
        "ADM20639" = "Server reboot requested"
        "AUT30685" = "Admin Login Auth Failure"
        "AUT23458" = "Signin Reject Admin Login"
        "ADM20447" = "Exported configuration by administrator %2"
        "ADM20444" = "Error while packing during export configuration by administrator"
        "ADM24205" = "Successfully exported configuration in XML to file"
        "ADM20655" = "Time zone changed"
        "ADM20640" = "Shutdown Server From Console"
        "ADM31101" = "Un-Official - Outgoing Traffic connection with IP and PORT"
        "ADM22820" = "Admin Idle Timeout By Request"
        "AUT30615" = "Admin Realm Restrictions Failed"
        "STS20641" = "Number of concurrent users logged in to the device"
        "ARC31800" = "Un-Official - Failed to upload file - Invalid Access key"
        "STS30667" = "Statistics - Number of NPC connections"
        "SYS32039" = "New files were found with the Internal Integrity Check Tool."
        "SYS32040" = "A modified file was found with the Internal Integrity Check Tool."
        "SYS32041" = "The Integrity Check Tool manifest file is missing."
        "SYS32042" = "The Integrity Checker Tool manifest file is bad."
        "SYS32087" = "A built-in integrity scan has started."
        "SYS32088" = "A built-in integrity scan has been completed."
        "SYS10306" = "System status - Starting services"
        "SYS32083" = "LMDB shards usage stats shard"
        "SYS31212" = "Un-Official - Certificate related log"
        "SYS31211" = "Un-Official - Certificate is about to expire"
        "LIC31493" = " Pulse Cloud Licensing Service - Heartbeat"
        "STS20142" = "Archived Statistics"
        "LIC10291" = "License Activated"
        "ARC24529" = "Skipping Archive"
        "LIC31494" = "Un-Official - License Heartbeat response"
        "LIC31495" = "Un-Official - License Related Log"
        "NET24463" = "Internal Interface UP"
        "NET24467" = "Internal Gateway Up"
        "NET24465" = "External Interface Up"
        "AUT32105" = "Un-Official - Retrieved all active sessions"
        "NET24469" = "External Gateway Up"
        "ADM22883" = "Site Minder server: Caches flushed."
        "SYS20413" = "Boot Success"
        "SYS20412" = "Booted - System started"
        "SYS10020" = "Excessive Write Tries Changes"
        "SYS10298" = "Server Reboot"
        "SYS10299" = "Server shutdown"
        "SYS31256" = "Un-Official - dsserver related log"

    }

    # Initialize an empty string to store processed lines
    $processedOutput = ""

    # Loop through each line
    foreach ($line in $logContent -split "`r`n") {
        # Update progress bar for line processing
        $processedLines++
        $percentComplete = [math]::Min(($processedLines / ($logContent -split "`r`n").Count) * 100, 100)  # Limit percentComplete to 100
        Write-Progress -Activity "Processing Log File" -Status "Processing lines" -PercentComplete $percentComplete

        # Check if the line starts with the specified pattern
        if ($line -match $startOfLineRegexPattern) {
            $matches = [regex]::Matches($line, $EpochRegexPattern)
            foreach ($match in $matches) {
                $epochTimestamp = $match.Groups[1].Value
                $convertedTimestamp = (Get-Date (Get-Date "1970-01-01 00:00:00").AddSeconds($epochTimestamp)).ToString("yyyy-MM-dd HH:mm:ss")
                $line = "$convertedTimestamp`t$line"
            }
        }

        # Split the line by whitespace while preserving tabs
        $words = $line -split '(\s+)'

        # Loop through each word
        foreach ($word in $words) {
            # Check if the word is a message code
            if ($messageCodeDescriptions.ContainsKey($word)) {
                # Replace the message code with its description
                $line = $line -replace [regex]::Escape($word), "$word`t$($messageCodeDescriptions[$word])"
            }
        }

        # Remove non-printable characters from the line while preserving spaces, tabs, and newline characters
        $cleanedLine = $line -replace "[^\x20-\x7E\t\r\n]", ""

        # Append the modified line to the processed output
        if (![string]::IsNullOrWhiteSpace($cleanedLine)) {
            $processedOutput += "$cleanedLine`n"
        }
    }

    # Clear existing output file
    Clear-Content -Path $outputFilePath -ErrorAction SilentlyContinue

    # Remove empty lines or lines with just one character
    $processedOutput = ($processedOutput -split "`n" | Where-Object { $_.Trim().Length -gt 1 }) -join "`n"
# Construct the output file path for CSV
$outputFileName = [System.IO.Path]::GetFileNameWithoutExtension($logFilePath) + "_parsed.csv"
$outputFilePath = [System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($logFilePath), $outputFileName)

# Generate column names
$columnNames = @(
    "Timestamp",
    "Log ID",
    "Device Hostname",
    "Msg Code",
    "Msg Description",
    "vc0",
    "Network",
    "Source IP Address",
    "User Name",
    "User Group",
    "Group Permission",
    "Unknown 13",
    "Unknown 14",
    "Unknown 15",
    "Unknown 16",
    "Agent Version",
    "Unknown 18",
    "Unknown 19",
    "Unknown 20",
    "UID",
    "API Request / VPN IP / Other",
    "Unknown 23",
    "Unknown 24",
    "Unknown 25"
)

# Replace (KHTML, with a placeholder to avoid breaking CSV structure
$processedOutput = $processedOutput -replace '\(KHTML,', 'PLACEHOLDER_KHTML'

# Define a regex pattern to match "(KHTML," within double quotes
$khtmlPattern = '"\(KHTML,"'

# Convert processed output to CSV format
$csvContent = $processedOutput -split "`n" | ForEach-Object {
    # Split each line by tabs and create an array
    $lineArray = $_ -split "`t" | ForEach-Object {
        # If the field contains "(KHTML," within double quotes, replace the double quotes with single quotes
        if ($_ -match $khtmlPattern) {
            $_ -replace '"', "'"
        } else {
            $_
        }
    }
    # Create a comma-separated string with text qualifier for fields containing commas
    $lineArray -join ","
}

# Construct the output file path for CSV
$outputFileName = [System.IO.Path]::GetFileNameWithoutExtension($logFilePath) + "_parsed.csv"
$outputFilePath = [System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($logFilePath), $outputFileName)

# Write the CSV content to the output file
$csvContent | ConvertFrom-Csv -Header $columnNames | Export-Csv -Path $outputFilePath -NoTypeInformation -Delimiter ',' -Encoding UTF8

# Notify the user about the completion and the location of the output CSV file
Write-Host "Log file parsed and converted to CSV format. Result saved to: $outputFilePath"

}

 else {
    Write-Host "Operation canceled by the user."
}