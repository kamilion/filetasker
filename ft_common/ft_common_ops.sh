# -----------
# FileTasker Common Operations Script
# -----------
# CMDLine Inputs: NIL (Not Executable)
# -----------
# Common Operations Functions
# Sourced by filetasker.sh
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

# These must match the sev_name translator.
MSG_TRACE=20
MSG_NOTICE=10
MSG_STATUS=7
MSG_INFO=5
MSG_CONSOLE=3
MSG_CRITICAL=2
MSG_ERROR=1

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
      echo "   Narration (SEV:`sev_name ${log_level}`): ${log_message}";
    else # Narration is off.
      if [[ -e "${script_path}/ft_config/ft_config_loud.on" ]]; then # Console chatter enabled?
        if [[ "${log_level}" -eq "${MSG_CONSOLE}" ]]; then # We only want messages marked CONSOLE.
          echo "  ${log_message}"; # Console messages go to the terminal.
        fi
      fi
    fi
  fi
  # Bugfix R207 - Add -e & \r to generate a carrage return for Windows' Notepad
  if [[ -e "${script_path}/ft_config/ft_config_logging.on" ]]; then # First check if logging is on.
    if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then # Then write *everything* to the tracelog.
      echo -e "(${log_timestamp})(SEV:`sev_name ${log_level}`): ${log_message}\r" >> "${logfile_path}${logfile_date}.${logfile_filename}.trace.log";
    fi
    if [[ "${log_level}" -le "${MSG_NOTICE}" ]]; then # Write low severity events only to the normal log.
      echo -e "(${log_timestamp})(SEV:`sev_name ${log_level}`): ${log_message}\r" >> "${logfile_path}${logfile_date}.${logfile_filename}.log";
    fi
  fi
}

# Trim the logfile if it gets too big
trim_log()
{
  log_size=`stat -c %s ${logfile_path}${logfile_date}.${logfile_filename}.log`   # Get Filesize
  if [ "${log_size}" -gt "${logfile_maxsize}" ]; # if it gets too big...
  then
    message_output ${MSG_CONSOLE} " Trimming log... ( ${log_size} bytes )"

    # Compress the old logfile
    message_output ${MSG_CONSOLE} " Compressing old log...";
    compress_gzip_file "${logfile_path}${logfile_date}.${logfile_filename}.log"
  else
    message_output ${MSG_CONSOLE} " Log does not need trimming. ( ${log_size} bytes )"
  fi
}

extend_line() { # Meant to be called via backticks.
  local numchars=${1}; local spacerline=""; # Set variables
  while [ $numchars -gt "0" ]; do
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
  if [ ${debug_dump_output} == "Y" ]
  then
    echo "Debug Dump in progress..."
    echo "dump_debug_message:" ${FUNCNAME[@]}
    echo "   Script Location:" ${script_location}
    echo "       Script Path:" ${script_path}
    echo "  Main Path Prefix:" ${main_path_prefix}
    echo "Source Path Prefix:" ${source_path_prefix}
    echo "Target Path Prefix:" ${target_path_prefix}
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

# Checks to see if $1 exists in array named $2
# Uses indirect variables to pass the array.
is_in_array() {
  local match=${1} # What text are we checking for?
  local input="$2[*]" # Indirection trick, add array selector BEFORE indirection.
  local ar_input=${!input} # Now we can use variable indirection on array data like "input[*]"!
  for i in ${ar_input[@]}; do # Because ${!input[*]} means list "array keys", not "array data"!
    if [[ ${match} == ${i} ]]; then return 0; fi; # Exists.
  done
  return 1; # Does not exist.
}

is_not_in_array() {
  local match=${1} # What text are we checking for?
  local input="$2[*]" # Indirection trick, add array selector BEFORE indirection.
  local ar_input=${!input} # Now we can use variable indirection on array data like "input[*]"!
  for i in ${ar_input[@]}; do # Because ${!input[*]} means list "array keys", not "array data"!
    if [[ ${match} == ${i} ]]; then return 1; fi; # Exists.
  done
  return 0; # Does not exist.
}

# Start Main Routines
# Default task_init function. Override me.
task_init_hook() { :; }
task_init()
{
  message_output ${MSG_CONSOLE} "Loaded taskfile ${task_name} at ${SECONDS} seconds."
  task_init_hook
}

# Selects a subtask to perform.
# Choices are currently: link, copy, move, debug
# noclobber is the default mode.
select_subtask()
{
  case "${1}" in
  "LINK" | "Link" | "link" )
    selected_subtask="link"
  ;;
  "COPY" | "Copy" | "copy" )
    selected_subtask="copy"
  ;;
  "MOVE" | "Move" | "move" )
    selected_subtask="move"
  ;;
  * )
    # Default to debug
    selected_subtask="debug"
  ;;
  esac
}

# Loads a taskfile
load_task()
{
  set_traps
  task_file="${script_path}/ft_tasks/${1}.sh"
  echo "   Loading Task: ${task_file}"
  # Does the taskfile exist?
  if [ -f "${task_file}" ]
  then
    # The task file exists! Source the file.
    source ${task_file}
  else
    echo "FATAL: Cannot find taskfile ${task_file}"
    exit ${E_MISSINGFILE}; # Throw an error
  fi
  # Run the task's initializer
  task_init
}

# Change directories to File Source Path
start_filetasker()
{
  message_output ${MSG_CONSOLE} "Traversing to Source Directory at ${SECONDS} seconds..."
  # Is the source path a directory?
  if [ -d ${source_path} ]
  then
    # Yes, it's a directory, descend into it.
    cd ${source_path}
  else
    # Wasn't a directory.
    message_output ${MSG_CONSOLE} "FATAL: Cannot find Taskfile's Source Directory ${source_path}"
    exit ${E_MISSINGFILE}; # Throw an error
  fi
  message_output ${MSG_CONSOLE} "Searching Source directory ${PWD}/ for ${file_ext} files"
}

# Change directories back to the previous working directory
quit_filetasker()
{
  # Head Home
  message_output ${MSG_CONSOLE} "Traversing back to Script Directory..."
  cd ${script_path}
  # Log too big?
  message_output ${MSG_CONSOLE} "Trimming log (If needed)...";
  # Close the log, show our times, then trim the log (Prevents leaving a one-line log after gz)
  message_output ${MSG_STATUS} "LOG SECTION END -- Script took ${SECONDS} seconds to complete all operations."
  trim_log
  echo ""
}

#Dummy functions to override from Taskfiles
task_pre() { :; }
task_post() { :; }
task_subtask() { :; }
task() { :; }
# End Main Routines

# -----------
# File Functions
# -----------

# Load Logging Operation Functions First
#source ${script_path}/ft_common/ft_logging_ops.sh

# Load File Operation Functions
source ${script_path}/ft_common/ft_file_ops.sh

# -----------
# Date Functions
# -----------

# Load Date Operation Functions
source ${script_path}/ft_common/ft_date_ops.sh


# -----------
# End Functions
# -----------

# -----------
# Main Program
# -----------

# Output Loader information
if [[ -e "${script_path}/ft_config/ft_config_quiet.off" ]]; then
  echo "  FileTasker Common Operations Module ${ftask_version} Loaded at ${SECONDS} seconds."; fi
# -----------
# End Main Program
# -----------
