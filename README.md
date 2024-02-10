# Ivanti-Secure-Connect-Logs-Parser
![Ivanti Secure Connect Logs Parser Menu Preview](https://github.com/david-abrgel/Ivanti-Secure-Connect-Logs-Parser/blob/9b90ce1c2fb0dccfaf8c4b5e1c89aa050cb436f3/Ivanti%20Secure%20Connect%20Logs%20Parser%20Menu%20Preview.png)
## Overview

The Ivanti Secure Connect Logs Parser is a PowerShell script designed to parse Ivanti Secure Connect runtime logs (in vc0 format) and convert them into a readable CSV format. This script provides a user-friendly menu selection interface, allowing users to choose the type of vc0 log (Admin, Events, or Access) they want to parse. It then prompts the user to select a log file for processing.

## Features

Menu Selection Interface: Users can easily select the type of vc0 log they want to parse (Admin, Events, or Access) through a menu interface.
Log File Selection: The script prompts users to select the log file they want to process, providing flexibility in file selection.
Automatic Conversion: The script automatically processes the selected log file, replacing message codes with their descriptions and epoch timestamps with human-readable dates.
Export to CSV: After processing, the script exports the parsed log data to a structured CSV format, making it easily readable and analyzable.
**Usage**
To use the Ivanti Secure Connect Logs Parser, follow these steps:

**Run the Script**: 
- **Execute**: Launch the PowerShell script Ivanti_Secure_Connect_Parser.ps1.
- **Select Log Type**: Choose the type of vc0 log you want to parse (Admin, Events, or Access).
- **Select Log File**: Select the specific log file you want to process.
- **Wait for Processing**: The script will automatically parse the log file and convert it into a CSV format.
- **View Results**: Once completed, the parsed log data will be saved to a CSV file, ready for viewing and analysis.

## Requirements

- PowerShell 3.0 or above
- Administrator mode
- Ivanti Secure Connect runtime logs in vc0 format

## Author

Author: David Abrgel
Version: 1.0.0
Date Created: 09/02/2024
