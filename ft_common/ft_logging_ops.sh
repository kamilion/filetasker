# -----------
# FileTasker Common Logging Operations Script
# -----------
# CMDLine Inputs: NIL (Not Executable)
# -----------
# Common Logging Operations Functions
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

# Start Debugging functions

# These must match the sev_name translator.
MSG_TRACE=20    # Trace messages.
MSG_NOTICE=10   # Notice messages.
MSG_STATUS=7    # Status messages.
MSG_INFO=5      # Informational messages.
MSG_VERBOSE=4  # "Verbose" console.
MSG_CONSOLE=3   # "Normal" console.
MSG_CRITICAL=2  # Critical failure. Bailout imminant.
MSG_ERROR=1     # Error messages.

sev_name() { # Meant to be called via backticks.
  case "${1}" in
  "1" )
    echo "   ERROR"
  ;;
  "2" )
    echo "CRITICAL"
  ;;
  "3" )
    echo " CONSOLE"
  ;;
  "4" )
    echo " VERBOSE"
  ;;
  "5" )
    echo "    INFO"
  ;;
  "7" )
    echo "  STATUS"
  ;;
  "10" )
    echo "  NOTICE"
  ;;
  "20" )
    echo "   TRACE"
  ;;
  * )
    # Default to UNKNOWN
    echo "  UNKNOWN"
  ;;
  esac
}

message_output()
{
  local log_level=${1}
  shift 1
  local log_message=${@}
  local log_timestamp=`date '+%F %T'`
  # Check for Low severity events.
  if [[ "${log_level}" -le "${MSG_NOTICE}" ]]; then # Check for low severity events
    if [[ -e "${script_path}/ft_config/ft_config_narration.on" ]]; then # Narration is on.
      echo -e "   Narration (SEV:`sev_name ${log_level}`): ${log_message}";
    else # Narration is off.
      if [[ "${log_level}" -eq "${MSG_CONSOLE}" ]]; then # We only want messages marked CONSOLE.
        echo -e "  ${log_message}"; # "Normal" Console messages *always* go to the terminal.
      fi
      if [[ -e "${script_path}/ft_config/ft_config_verbose.on" ]]; then # "Verbose" Console chatter enabled?
        if [[ "${log_level}" -eq "${MSG_VERBOSE}" ]]; then # We only want messages marked VERBOSE.
          echo -e "  ${log_message}"; # "Loud" Console messages sometimes go to the terminal.
        fi
      fi
    fi
  fi
  # Bugfix R207 - Add -e & \r to generate a carrage return for Windows' Notepad
  if [[ -e "${script_path}/ft_config/ft_config_logging.on" ]]; then # First check if logging is on.
    if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then # Then write *everything* to the tracelog.
      echo -e "(${log_timestamp})(SEV:`sev_name ${log_level}`): ${log_message}\r" >> "${logfile_path}${logfile_date}.${logfile_tracename}.trace.log";
    fi
    if [[ "${log_level}" -le "${MSG_NOTICE}" ]]; then # Write low severity events only to the normal log.
      echo -e "(${log_timestamp})(SEV:`sev_name ${log_level}`): ${log_message}\r" >> "${logfile_path}${logfile_date}.${logfile_filename}.log";
    fi
  fi
}

# Switch logfile names
switch_to_log()
{ # Inputs: $1 - Log Description to switch to
  add_logfile_to_trimlist ${1}
  logfile_filename="${1}"
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
{
  for log_filename in ${ar_logfiles[@]}
    do
      trim_log ${log_filename}
    done
}

# Trim the logfile if it gets too big
trim_log()
{ # Inputs: $1 - Filename to trim
  local log_size=`stat -c %s ${logfile_path}${logfile_date}.${1}.log`   # Get Filesize
  if [[ "${log_size}" -gt "${logfile_maxsize}" ]]; # if it gets too big...
  then
    message_output ${MSG_VERBOSE} " Trimming log ${1}... ( ${log_size} bytes )"

    # Compress the old logfile
    message_output ${MSG_VERBOSE} " Compressing old log...";
    compress_gzip_file "${logfile_path}${logfile_date}.${1}.log"
  else
    message_output ${MSG_VERBOSE} " Log ${1} does not need trimming. ( ${log_size} bytes )"
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
{
  message_output ${MSG_INFO} "======="`extend_line ${#1}`"======="
  message_output ${MSG_INFO} "====== ${1} ======"
  message_output ${MSG_INFO} "======="`extend_line ${#1}`"======="
}

# Signal Traps
set_traps()
{
  # Set trap for signal DEBUG (DEBUG)
  #trap "trap_debug_dump" DEBUG
  # Set trap for signal 0 (EXIT)
  trap "trap_exit_dump" EXIT
  # Set trap for signal 1 (HUP)
  trap "trap_bail_out 1 HANGUP" SIGHUP
  # Set trap for signal 2 (QUIT)
  trap "trap_bail_out 2 QUIT" SIGQUIT
  # Set trap for signal 3 (INT)
  trap "trap_bail_out 3 INTERRUPT" SIGINT
  # Set trap for signal 15 (TERM)
  trap "trap_bail_out 15 TERM" SIGTERM
  # Display all set traps
  #trap -p
}

# Generic bailout
debug_dump_output=N
trap_bail_out()
{
  message_output ${MSG_CRITICAL} "  Trapped Signal ${1} (${2}), bailing out..."
  message_output ${MSG_CRITICAL} "  Trapped Current File Name:" ${file_name}
  message_output ${MSG_CRITICAL} "  Trapped Call Stack:" ${FUNCNAME[@]}
  echo "  Trapped Signal ${1} (${2}), bailing out..."
  debug_dump_output=Y
  quit_filetasker
  exit 0
}

# Debugging variable dumpers
trap_debug_dump()
{
    echo "Call Stack:" ${FUNCNAME[@]}
    message_output ${MSG_TRACE} "Call Stack:" ${FUNCNAME[@]}
}

trap_exit_dump()
{
  if [[ ${debug_dump_output} == "Y" ]]
  then
    echo "Debug Dump in progress..."
    echo "dump_debug_message:" ${FUNCNAME[@]}
    echo "   Script Location:" ${script_location}
    echo "       Script Path:" ${script_path}
    echo "  Main Path Prefix:" ${main_path_prefix}
    echo "Source Path Prefix:" ${source_path_prefix}
    echo "       Source Path:" ${source_path}
    echo "Target Path Prefix:" ${target_path_prefix}
    echo "       Target Path:" ${target_path}
    echo "           FT_Args:" ${ft_args[*]}
    echo "         Task Name:" ${task_name}
    echo "      Subtask Name:" ${subtask_name}
    echo " Current File Name:" ${file_name}
    trap_debug_task_dump
  fi
}

# Override this in the task
trap_debug_task_dump()
{
  :;
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
  echo "  FileTasker Common Logging Module ${ftask_version} Loaded at ${SECONDS} seconds."; fi
# -----------
# End Main Program
# -----------
