# -----------
# FileTasker Console Logging Operations Script
# -----------
# CMDLine Inputs: NIL (Not Executable)
# -----------
# Console Logging Operations Functions
# Sourced by ft_logging_ops.sh
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

# Start Debugging functions

message_output_to_console() # Logging to console
{ # Inputs: $1 - log_level, $2 - log_timestamp, $3 - log_message
  # Check for Low severity events.
  if [[ "${1}" -le "${MSG_NOTICE}" ]]; then # Check for low severity events
    if [[ -e "${script_path}/ft_config/ft_config_narration.on" ]]; then # Narration is on.
      echo -e "   Narration (SEV:`sev_name ${1}`): ${3}";
    else # Narration is off.
      if [[ "${1}" -eq "${MSG_CONSOLE}" ]]; then # We only want messages marked CONSOLE.
        echo -e "  ${3}"; # "Normal" Console messages *always* go to the terminal.
      fi
      if [[ -e "${script_path}/ft_config/ft_config_verbose.on" ]]; then # "Verbose" Console chatter enabled?
        if [[ "${1}" -eq "${MSG_VERBOSE}" ]]; then # We only want messages marked VERBOSE.
          echo -e "  ${3}"; # "Loud" Console messages sometimes go to the terminal.
        fi
      fi
    fi
  fi
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
  echo "  FileTasker Console Logging Module Loaded at ${SECONDS} seconds."; fi
# -----------
# End Main Program
# -----------
