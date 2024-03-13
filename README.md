# Ivanti Secure Connect Logs Parser v2.0.0.0

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

## Solved Issues Issues in Version 2.0.0
- The script **can** handle large vc0 files battle-tested for files weighing between 300MB-500MB very well due to a 7-step proceesing,
  which is utilizing the .NET function of file streaming and using a buffer with "chunk" method.
  
### Planned Improvements for Next Version

- **Adding More Message Codes and Descriptions**: Identify and incorporate additional message codes and their descriptions to improve the comprehensiveness of the log parsing process.
> For a comprehensive list of message codes and their descriptions, refer to the [Pulse Policy Secure Error Message Guide](https://help.ivanti.com/ps/legacy/PPS/9.1Rx/9.1R9/Pulse-Policy-Secure-Error-Message-Guide.pdf) provided by Ivanti.


- **Refining Unknown Columns**: Investigate the purpose and content of currently "unknown columns" in the CSV output and provide appropriate names and descriptions for better clarity.
  
- **Complete support for all vc0 files** the runtime folder holds 6 different ".vc0" log files:

| Log Name      | File Path                              | Featured ?
|---------------|----------------------------------------|---------------|  
| **events**        | **/runtime/logs/log.events.vc0**           | ✅        |  
| **admin**         | **/runtime/logs/log.admin.vc0**            | ✅        |   
| **access**        | **/runtime/logs/log.access.vc0**           | ✅        |  
| diagnosticlog | /runtime/logs/log.diagnosticlog.vc0    | ✅         |  
| policytrace   | /runtime/logs/log.policytrace.vc0      | ✅         |  
| sensorslog    | /runtime/logs/log.sensorslog.vc0       | ✅        |   

The un-featured logs will hopefully will be added in the next versions

## Usage

1. **Run the Script**:
   - Execute the PowerShell script "Invati Secure Connect Logs Parser.ps1".
   
2. **Select Log Type**:
   - Choose the type of vc0 log you want to parse (Admin, Events, or Access).

3. **Select Log File**:
   - Select the specific log file you want to process.

4. **Wait for Processing**:
   - The script will automatically parse the log file and convert it into a CSV format.

5. **View Results**:
   - Once completed, the parsed log data will be saved to a CSV file, ready for viewing and analysis.

## Requirements

- :heavy_check_mark: PowerShell 3.0 or above
- :lock: Administrator mode
- :file_folder: Ivanti Secure Connect runtime logs in vc0 format

## Author

- Author: David Abrgel
- Version: 2.0.0
- Date Created: 09/02/2024
- Update Release Date: 13/03/2023

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

