# -----------
# FileTasker File Logging Operations Script
# -----------
# CMDLine Inputs: NIL (Not Executable)
# -----------
# File Logging Operations Functions
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

ar_logfiles=(  );

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

# Start Debugging File functions

message_output_to_file() # Logging to files
{ # Inputs: $1 - log_level, $2 - log_timestamp, $3 - log_message
  # Bugfix R207 - Add -e & \r to generate a carrage return for Windows' Notepad
  if [[ -e "${script_path}/ft_config/ft_config_logging.on" ]]; then # First check if logging is on.
    if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then # Then write *everything* to the tracelog.
      echo -e "(${2})(SEV:`sev_name ${1}`): ${3}\r" >> "${logfile_path}${logfile_date}.${logfile_tracename}.trace.log";
    fi
    if [[ "${log_level}" -le "${MSG_NOTICE}" ]]; then # Write low severity events only to the normal log.
      echo -e "(${2})(SEV:`sev_name ${1}`): ${3}\r" >> "${logfile_path}${logfile_date}.${logfile_filename}.log";
    fi
  fi
}

# Switch logfile names
switch_to_log()
{ # Inputs: $1 - Log Description to switch to
  add_logfile_to_trimlist ${1};
  logfile_filename="${1}";
}

# Add a log file to the list for trimming
add_logfile_to_trimlist()
{ # Inputs: $1 - Filename to add to ar_logfiles
  if is_not_in_array "${1}" "ar_logfiles"; then
    ar_logfiles=( "${ar_logfiles[@]}" "${1}" ); # add to array
  fi
}

# Trim logfiles
trim_logs()
{ # Inputs: NIL
  for log_filename in ${ar_logfiles[@]}
    do
      trim_log ${log_filename};
    done
}

# Trim the logfile if it gets too big
trim_log()
{ # Inputs: $1 - Filename to trim
  local log_size=`stat -c %s ${logfile_path}${logfile_date}.${1}.log`;  # Get Filesize
  if [[ "${log_size}" -gt "${logfile_maxsize}" ]]; # if it gets too big...
  then
    message_output ${MSG_VERBOSE} " Trimming log ${1}... ( ${log_size} bytes )";

    # Compress the old logfile
    message_output ${MSG_VERBOSE} " Compressing old log...";
    compress_gzip_file "${logfile_path}${logfile_date}.${1}.log";
  else
    message_output ${MSG_VERBOSE} " Log ${1} does not need trimming. ( ${log_size} bytes )";
  fi
}

extend_line() { # Meant to be called via backticks.
  local numchars=${1}; local spacerline=""; # Set variables
  while [[ $numchars -gt "0" ]]; do
    spacerline="${spacerline}="; # Append one more spacer
    ((numchars--)); done; # Decrease the counter
  echo $spacerline; # Output the final line
}

make_line_header()
{ # Inputs: $1 - Message to be encapsulated
  message_output ${MSG_INFO} "======="`extend_line ${#1}`"=======";
  message_output ${MSG_INFO} "====== ${1} ======";
  message_output ${MSG_INFO} "======="`extend_line ${#1}`"=======";
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
  echo "  FileTasker File Logging Module Loaded at ${SECONDS} seconds."; fi
# -----------
# End Main Program
# -----------
