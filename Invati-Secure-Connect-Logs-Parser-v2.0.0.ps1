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
    4: Diagnostic log 
    5: Sensor log
    6: Policy trace

.EXAMPLE
    .\Ivanti_Secure_Connect_Parser.ps1
    Prompts the user to select the type of vc0 log and the log file to process.

.NOTES
    Author: David Abrgel
    Version: 2.0.0
    Date Created: 09/02/2024
	Latest Version Release: 13/03/2024
    Requirements: PowerShell 3.0 or above, Administrator mode and Ivanti Secure Connect runtime logs in vc0 format.

#>


# Menu selection for the type of vc0 log
Write-Host "                                                                                       "
Write-Host "                                                                                       "
Write-Host "                                #######################################################" 
Write-Host "                                #           Ivanti Secure Connect Logs Parser         #" 
Write-Host "                                #                                                     #" 
Write-Host "                                #       Converting Runtime Logs Into Readable Log     #" 
Write-Host "                                #                                                     #" 
Write-Host "                                #                  Version: 2.0.0                     #" 
Write-Host "                                #                                                     #" 
Write-Host "                                #######################################################" 
Write-Host "                                                                                       "
Write-Host "                                Select the type of vc0 log:                            " -ForegroundColor Green
Write-Host "                                                                                       "
Write-Host "                                1. Admin                                               "
Write-Host "                                2. Events                                              "
Write-Host "                                3. Access                                              "
Write-Host "                                4. Diagnostic log                                      "
Write-Host "                                5. Sensor log                                          "
Write-Host "                                6. Policy trace                                        "
Write-Host "                                                                                       "
$selection = Read-Host "Enter your choice (1, 2, 3, 4, 5, 6)"

# Validate the selection
if ($selection -notin '1', '2', '3', '4', '5', '6') {
    Write-Host "Invalid selection. Please choose 1, 2, 3, 4, 5 or 6."
    exit
}

# Prompt the user to select a file using OpenFileDialog
Add-Type -AssemblyName System.Windows.Forms
$fileDialog = New-Object System.Windows.Forms.OpenFileDialog
$fileDialog.InitialDirectory = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Definition)
$fileDialog.Title = 'Select a log file'

# Validate the selection
if ($selection -notin '1', '2', '3', '4', '5', '6') {
    Write-Host "Invalid selection. Please choose 1, 2, 3, 4, 5 or 6"
    exit
}

# Define file filter based on the user's selection
switch ($selection) {
    '1' { $fileDialog.Filter = 'Admin logs (*.admin.vc0;*.admin.vc0.old)|*.admin.vc0;*.admin.vc0.old|All files (*.*)|*.*' }
    '2' { $fileDialog.Filter = 'Events logs (*.events.vc0;*.events.vc0.old)|*.events.vc0;*.events.vc0.old|All files (*.*)|*.*' }
    '3' { $fileDialog.Filter = 'Access logs (*.access.vc0;*.access.vc0.old)|*.access.vc0;*.access.vc0.old|All files (*.*)|*.*' }
    '4' { $fileDialog.Filter = 'Diagnostic logs (*.diagnosticlog.vc0;*.diagnosticlog.vc0.old)|*.diagnosticlog.vc0;*.diagnosticlog.vc0.old|All files (*.*)|*.*' }
    '5' { $fileDialog.Filter = 'Sensor log (*.sensorslog.vc0;*.sensorslog.vc0.old)|*.sensorslog.vc0;*.sensorslog.vc0.old|All files (*.*)|*.*' }
    '6' { $fileDialog.Filter = 'Policy trace (*.policytrace.vc0;*.policytrace.vc0.old)|*.policytrace.vc0;*.policytrace.vc0.old|All files (*.*)|*.*' }
}

# Show the file dialog and get the result
$result = $fileDialog.ShowDialog()

if ($result -ne 'OK') {
    Write-Host "Operation canceled by the user."
    exit
}

# Get the selected file path
$logFilePath = $fileDialog.FileName

if ($result -eq 'OK') {
    $logFilePath = $fileDialog.FileName

# Step one Script - clean first 8k bytes
write-host "Step 1 - Removing null header of first 8k bytes.."

# Specify the path to the input file
$inputFilePath = $logFilePath

# Get the directory path and file name without extension of the selected file
$outputDirectory = Split-Path -Path $logFilePath -Parent
$fileNameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($logFilePath)

# Specify the path to the output file
$outputFilePath_step_1 = Join-Path -Path $outputDirectory -ChildPath "${fileNameWithoutExtension}_temp_step_1.txt"

# Open the input file using a .NET FileStream
$fileStream = [System.IO.File]::OpenRead($inputFilePath)

# Skip the first 8192 bytes
$fileStream.Seek(8192, [System.IO.SeekOrigin]::Begin)

# Create a StreamReader to read from the file stream
$streamReader = [System.IO.StreamReader]::new($fileStream)

# Open the output file for writing
$outputFile = [System.IO.StreamWriter]::new($outputFilePath_step_1)

try {
    # Read each line from the input file and process it
    while (-not $streamReader.EndOfStream) {
        $line = $streamReader.ReadLine()
        $outputFile.WriteLine($line)
    }

}
finally {
    # Close the StreamReader, the file stream, and the output file
    $streamReader.Close()
    $fileStream.Close()
    $outputFile.Close()
    Write-Host "Removed 8k bytes header"
}

# Step 2 script to remove non-printing characters and control characters for end of line indication
# Also this script will remove the leading space in a line
Write-Host "Step 2 - Cleaning non-printing characters ..." 
# Define the input and output file paths
$inputFile = $outputFilePath_step_1
$outputFile_step_2 = Join-Path -Path $outputDirectory -ChildPath "${fileNameWithoutExtension}_temp_step_2.txt"

# Open the input file for reading
$reader = [System.IO.StreamReader]::new($inputFile)

# Open the output file for writing
$writer = [System.IO.StreamWriter]::new($outputFile_step_2, [System.Text.Encoding]::UTF8)

# Process the file line by line
try {
    while ($reader.Peek() -ge 0) {
        $line = $reader.ReadLine()

        # Replace STX and SOH characters with LF
        $line = $line -replace "[\x17\x15\x13\x12\x05\x04\x03\x02\x01\x00]", "`n"

        # Replace NON-Printing characters with space
        $line = $line -replace "[\x07]", " "

        # Remove Non-Printing characters with blank
        $line = $line -replace "[\x0B\x1C\x0F\x06\x1E\x08\x10\x1D\x0E\x11\x14\x16\x17\x18\x19\x1F\x7F\x1A\x1B\x0C\uFFFD]", ""

        # Remove leading space in the start of the line
        $line = $line -replace "^(\s)+65.*$", ""

        # Skip lines with less than 2 characters
        if ($line.Length -lt 2) {
        # Skip the line
        } else {
        # Write the cleaned line to the output file
        $writer.WriteLine($line)
    }
}
} finally {
    # Close the input and output streams
    $reader.Close()
    $writer.Close()
    write-host "Cleaned log file from non printing characters"
    #Remove step 1 Temp File
}


# Step 3 - Removing empty lines and excessive characters at end of line
write-host "Step 3 - Removing empty lines and excessive characters at the end of line ..."
# Define the input and output file paths
$inputFile = $outputFile_step_2
$outputFile_step_3 = Join-Path -Path $outputDirectory -ChildPath "${fileNameWithoutExtension}_temp_step_3.txt"


# Open the input file for reading
$reader = [System.IO.StreamReader]::new($inputFile)

# Open the output file for writing
$writer = [System.IO.StreamWriter]::new($outputFile_step_3, $false, [System.Text.Encoding]::UTF8)

# Process the file line by line
try {
    while ($reader.Peek() -ge 0) {
        $line = $reader.ReadLine()

        # Remove leading space in the start of the line
        $line = $line -replace "^(\s)+65.*$", ""

        # Replace comma with hypen
        $line = $line -replace ",", "-"

        # Remove excessive single characters in end of line
        $line = $line -replace '\t"$', ""

        # Remove excessive single characters in end of line
        $line = $line -replace '\t.{1}$', ""

        # Reduce excessive 4 consecutive tabs to a single tab
        $line = $line -replace '(\t{4})', "`t"

        # Skip lines with less than 2 characters
        if ($line.Length -lt 2) {
            # Skip the line
        }
        # Skip lines that match the specified regex patterns
        elseif ($line -match '^\s+{.*$' -or $line -match '^\s+10.*$') {
            # Skip the line
        }
        else {
            # Write the cleaned line to the output file
            $writer.WriteLine($line)
        }
    }

} finally {
    # Close the input and output streams
    $reader.Close()
    $writer.Close()
    write-host "Removed empty lines and excessive characters at the end of line"
}

# Step 4 - Converting timestamp
write-host "Step 4- Converting timestamps..."
# Function to convert a hexadecimal string to decimal
function Convert-HexToDecimal {
    param (
        [string]$hex
    )

    return [convert]::ToInt32($hex, 16)
}

# Function to convert an epoch timestamp to a human-readable ISO8601 format
function Convert-EpochToISO8601 {
    param (
        [long]$epoch
    )

    # Define the Unix epoch start date
    $epochStartDate = Get-Date -Year 1970 -Month 1 -Day 1 -Hour 0 -Minute 0 -Second 0 -Millisecond 0

    # Add the epoch time (in seconds) to the epoch start date
    $dateTime = $epochStartDate.AddSeconds($epoch)

    # Convert DateTime to ISO8601 format
    return $dateTime.ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss")
}

# Main script logic
$inputFile = $outputFile_step_3
$outputFile_step_4 = Join-Path -Path $outputDirectory -ChildPath "${fileNameWithoutExtension}_temp_step_4.txt"

$reader = [System.IO.StreamReader]::new($inputFile)
$writer = [System.IO.StreamWriter]::new($outputFile_step_4)

try {
    while (($line = $reader.ReadLine()) -ne $null) {
        $parts = $line -split '\.'
        $firstPart = $parts[0]

        # Check if the first part matches the regex pattern
        if ($firstPart -match "(65[a-zA-Z0-9]+)") {
            $matchedPart = $matches[0]
            
            # Convert the hexadecimal part to decimal
            $hexPart = $matchedPart
            $decimalPart = Convert-HexToDecimal -hex $hexPart

            # Convert the decimal part from epoch timestamp to ISO8601 format
            $iso8601Timestamp = Convert-EpochToISO8601 -epoch $decimalPart

            # Prepend the ISO8601 timestamp to the beginning of the line
            $line = "$iso8601Timestamp`t" + ($parts -join '.')
        }

        # Write the modified line to the output file
        $writer.WriteLine($line)
    }
}
finally {
    # Close the reader and writer
    $reader.Close()
    $writer.Close()
    Write-host "Timestamps converted"
}


#Step 5 - Converting message codes"
Write-Host "Step 5 - Converting message codes ..."
# Specify the path to the log file
$logFilePath = $outputFile_step_4

# Prompt the user to select the CSV file
$fileDialog = [System.Windows.Forms.OpenFileDialog]@{
    InitialDirectory = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Definition)
    Title = 'Select the CSV file containing message descriptions and categories'
    Filter = 'CSV files (*.csv)|*.csv|All files (*.*)|*.*'
}

$result = $fileDialog.ShowDialog()

if ($result -eq 'OK') {
    $csvFilePath = $fileDialog.FileName
}
else {
    Write-Host "Operation canceled by the user."
    exit
}

# Open the log file using a .NET StreamReader
$logStreamReader = [System.IO.StreamReader]::new($logFilePath)

# Load CSV data into a hashtable for faster lookup
$csvLookup = @{}
Import-Csv $csvFilePath -Delimiter "`t" | ForEach-Object {
    $csvLookup[$_.MsgCode] = "$($_.MsgDescription)`t$($_.Category)"
}

# Open the output file for writing
$outputFilePath = Join-Path -Path $outputDirectory -ChildPath "${fileNameWithoutExtension}_Parsed_final.txt"
$outputFile = [System.IO.StreamWriter]::new($outputFilePath, [System.Text.Encoding]::UTF8)

try {
    Write-Host "Processing log file..."

    # Open the log file using a .NET StreamReader
    $logStreamReader = [System.IO.StreamReader]::new($logFilePath)

    # Read each line from the log file and process it
    while (-not $logStreamReader.EndOfStream) {
        $line = $logStreamReader.ReadLine()
        
        # Split the line by tab characters
        $fields = $line -split "`t"
        
        # Check if there are at least 4 fields
        if ($fields.Count -ge 4) {
            $lineID = $fields[2]  # Assuming the line ID is in the second field
            $messageCode = $fields[3]  # Assuming the message code is in the fourth field
            
            # Check if there is a matching entry in the CSV lookup table
            if ($csvLookup.ContainsKey($messageCode)) {
                $descriptionAndCategory = $csvLookup[$messageCode]
                
                # Find the position of the message code within the line
                $index = $line.IndexOf($messageCode)
                
                # Insert the description and category right after the message code
                $line = $line.Insert($index + $messageCode.Length, "`t$descriptionAndCategory")
            }
            else {
                Write-Host "No matching entry found for message code: $messageCode (Line ID: $lineID)"
            }
        }
            else {
            $firstTwoFields = $fields[0..1] -join "`t"
            Write-Host "Line does not contain at least 4 fields. First two fields: $firstTwoFields"
        }

        $outputFile.WriteLine($line)
    }

}
finally {
    # Close the file streams
    Write-Host "Closing file streams..."
    $logStreamReader.Close()
    $outputFile.Close()
    $reader.Close()
    $writer.Close()
    $reader = $null
    $writer = $null
    Write-Host "File Parsed successfuly ..."
}
    # 6th step - Convert parsed log file to CSV
    Write-Host "Step 6 - Convert parsed log file to CSV..."

    # Ask the user if they want to convert to CSV
    $convertToCsv = Read-Host "Do you want to convert the parsed log file to CSV? (Y/N)"
    if ($convertToCsv -eq 'Y' -or $convertToCsv -eq 'y') {
    # Specify the path to the input file
    $parsed_inputFilePath = $outputFilePath

    # Specify the path to the output CSV file
    $outputFilePath_csv = Join-Path -Path $outputDirectory -ChildPath "${fileNameWithoutExtension}_Parsed_final.csv"

    # Define the chunk size (adjust as needed)
    $chunkSize = 8192  # You can adjust this value based on your needs

    try {
        Write-Host "Opening input file..."
        # Open the input file using a .NET FileStream
        $fileStream = [System.IO.File]::OpenRead($parsed_inputFilePath)

        Write-Host "Creating StreamReader..."
        # Create a StreamReader to read from the file stream
        $streamReader = [System.IO.StreamReader]::new($fileStream)

        Write-Host "Opening output CSV file..."
        # Open the output CSV file for writing
        $csvFile = [System.IO.StreamWriter]::new($outputFilePath_csv)

        # Write the CSV header (if needed)
        $csvFile.WriteLine("Timestamp,Line ID,Device Hostname,Msg Code,Msg Description,Msg Category,Log Source Type,Device Network,Source IP,Msg Data 10,Msg Data 11,Msg Data 12,Msg Data 13,Msg Data 14,Msg Data 15,Msg Data 16,Msg Data 17,Msg Data 18,Msg Data 19,Msg Data 20,Msg Data 21,Msg Data 22,Msg Data 23,Msg Data 24,Msg Data 25,Msg Data 26,Msg Data 27,Msg Data 28,Msg Data 29,Msg Data 30")

        # Define a buffer to read the file in chunks
        $buffer = New-Object byte[] $chunkSize

        Write-Host "Processing file..."
        # Process the file in chunks
        while (-not $streamReader.EndOfStream) {
            # Read a chunk of data from the input file
            $line = $streamReader.ReadLine()

            # Process the line (parse and format as CSV)
            $csvLine = $line -replace "\t", ","
            $csvFile.WriteLine($csvLine)
        }
        Write-Host "File processing complete."
    }
    finally {
        # Close the file streams
        if ($streamReader) { 
            Write-Host "Closing input file..."
            $streamReader.Close() 
        }
        if ($fileStream) { 
            $fileStream.Close() 
        }
        if ($csvFile) { 
            Write-Host "Closing output CSV file..."
            $csvFile.Close() 
        }
    }
} else {
    Write-Host "CSV conversion skipped."
}

# 7th step - Ask if the user wants to preserve temporary files
# Ask the user if they want to preserve the temporary files
$preserveTempFiles = Read-Host "Do you want to preserve the temporary files? (Y/N)"
if ($preserveTempFiles -eq 'N' -or $preserveTempFiles -eq 'n') {
    # Remove temporary files
    Remove-Item $outputFilePath_step_1
    Remove-Item $outputFile_step_2
    Remove-Item $outputFile_step_3
    Remove-Item $outputFile_step_4
} else {
    Write-Host "Temporary files preserved."
}

}

 else {
    Write-Host "Operation canceled by the user."
}