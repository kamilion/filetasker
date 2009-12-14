# -----------
# FileTasker Core Modular Logging Operations Script
# -----------
# CMDLine Inputs: NIL (Not Executable)
# -----------
# Core Modular Logging Operations Functions
# Sourced by ft_common_ops.sh
# -----------
# End Program Information
# -----------

# -----------
# Variable Defaults
# -----------

# -----------
# Arrays
# -----------

# -----------
# Strings
# -----------

# -----------
# Paths
# -----------

# -----------
# End Variables
# -----------

# -----------
# Functions
# -----------

# Load Logging Common Operation Functions
source ${script_path}/ft_common/ft_logging_ops.sh;

# Load Logging File Operation Functions
source ${script_path}/ft_common/ft_logging_console.sh;

# Load Logging File Operation Functions
source ${script_path}/ft_common/ft_logging_files.sh;

# Load Database Logging Operation Functions
source ${script_path}/ft_common/ft_logging_db.sh;

# Start Debugging functions

# All output is directed here. Modules do their own severity filtering.
message_output()
{ # Inputs: $1 - Numeric Severity Level, $2 - Log Message
  local log_level=${1}; shift 1; local log_message=${@}; # Capture Severity & Message
  local log_timestamp=`date '+%F %T'`; # Generate log timestamp
  message_output_to_console "${log_level}" "${log_timestamp}" "${log_message}";
  message_output_to_file "${log_level}" "${log_timestamp}" "${log_message}";
  #message_output_to_database "${log_level}" "${log_timestamp}" "${log_message}";
}

# End Debugging functions

# End Main Routines

# -----------
# End Functions
# -----------

# -----------
# Main Program
# -----------

# Output Loader information
if [[ -e "${script_path}/ft_config/ft_config_verbose.on" ]]; then
  echo "  FileTasker Core Logging Module Loaded at ${SECONDS} seconds."; fi
# -----------
# End Main Program
# -----------
