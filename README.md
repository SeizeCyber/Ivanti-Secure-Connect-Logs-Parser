# Ivanti Secure Connect Logs Parser v2.0.0

![Ivanti-Secure-Connect-Logs-Parser-v2](https://github.com/SeizeCyber/Ivanti-Secure-Connect-Logs-Parser/assets/42407252/6424f7e1-c48c-4a8a-ae54-c57d9bb21705)





## Overview

The Ivanti Secure Connect Logs Parser is a PowerShell script designed to parse Ivanti Secure Connect runtime logs (in vc0 format).  
It converts various strings to ease the analysis efforts and converts them into a readable CSV format.  
  
For example, the original ".vc0" logs hold the epoch timestamp in base16 in the start of line befor the dot:  
- **"65f221e0.07357a"** which after conversion will show this date and time: "2024-3-13 22:00:00".
  
And a message like:  
- **"AUT24326"**  which stands for "Log Auth Success".

This tool provides a user-friendly interface, allowing users to select the type of vc0 log (Admin, Events, or Access) for parsing.  
It then prompts the user to choose a log file for processing.

## Features

- :gear: **Log Type Selection Menu**: Users can choose the type of vc0 log they want to parse: Admin, Events, or Access logs.
  
- :alarm_clock: **Epoch Timestamp Conversion**: The script identifies epoch timestamps in the vc0 log files and converts them into human-readable dates for better understanding.

- :label: **Message Code Descriptions**: Message codes in the logs are replaced with their corresponding descriptions, making it easier to interpret the log entries.

- :page_with_curl: **CSV Output**: Parsed log entries are exported to a structured CSV format, facilitating analysis and further processing.

- :warning: **Error Handling**: The script provides error handling to manage invalid user inputs and ensure smooth execution.

  
### Improvements Added In Version 2.0.0
- **Support and Enhanced Performance for Large Files:**
The parser has undergone rigorous testing and optimization to handle large vc0 log files efficiently. It has been battle-tested on files weighing between 300-500 MB, ensuring reliable processing even with extensive data volumes,
this was achieved by building a 7-step process that relies on writing log files into temporary files on disk utilizing the file stream function in .NET and using the buffering support to gain a faster and more stable parser flow.

-**Improved Message Code Conversion:** 
With an expanded database containing over 8,000 message codes sourced from the latest "ive.msgs" dataset, the parser offers enhanced accuracy and comprehensiveness in converting message codes to their respective descriptions and categories.
> For a comprehensive list of message codes and their descriptions, refer to the [Pulse Policy Secure Error Message Guide](https://help.ivanti.com/ps/legacy/PPS/9.1Rx/9.1R9/Pulse-Policy-Secure-Error-Message-Guide.pdf) provided by Ivanti.


- **Stabilized CSV Column Names**: Additional Column names were added to clarify the purpose of the various fields, for the versatile fields it was changed to “msg data” and a number.
  
- **Complete support for all vc0 files** the runtime folder holds 6 different ".vc0" log files:

| Log Name      | File Path                              | Featured ?
|---------------|----------------------------------------|---------------|  
| **events**        | **/runtime/logs/log.events.vc0**           | ✅        |  
| **admin**         | **/runtime/logs/log.admin.vc0**            | ✅        |   
| **access**        | **/runtime/logs/log.access.vc0**           | ✅        |  
| diagnosticlog | /runtime/logs/log.diagnosticlog.vc0    | ✅         |  
| policytrace   | /runtime/logs/log.policytrace.vc0      | ✅         |  
| sensorslog    | /runtime/logs/log.sensorslog.vc0       | ✅        |   


## Usage

1. **Run the Script**:
   - Execute the PowerShell script "Invati Secure Connect Logs Parser.ps1".
   
2. **Select Log Type**:
   - Choose the type of vc0 log you want to parse (Admin, Events, or Access).

3. **Select Log File**:
   - Select the specific log file you want to process.

4. **Wait for Processing**:
   - The script will automatically parse the log file and will ask  if a convesion into a CSV format is wanted.

5. **View Results**:
   - Once completed, the parsed log data will be saved to a TXT or CSV file based on your choice, ready for viewing and analysis.

## Requirements

- Running with PowerShell ISE to support .NET open file dialog
- :heavy_check_mark: PowerShell 3.0 or above
- :lock: Administrator mode
- :file_folder: Ivanti Secure Connect runtime logs in vc0 format


## Author

- Author: David Abrgel
- Version: 2.0.0
- Date Created: 09/02/2024
- Update Release Date: 13/03/2024

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

