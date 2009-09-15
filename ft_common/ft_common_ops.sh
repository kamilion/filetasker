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

# Path to write logs & tracefiles to
logfile_path="${script_path}/ft_logs/"
# Define the logfilename backup 'generic' date format: YYYYMMDD_HHMMSS
logfile_backup_date=`date +%Y%0m%0d_%0H%0M%0S`
# This is the default log file name if a task does not redefine it.
logfile_filename="filetasker.log"

MSG_CRITICAL=15
MSG_TRACE=10
MSG_NOTICE=5
MSG_INFO=1

message_output()
{
  local log_level=${1}
  local log_message=${2}
  local log_timestamp=`date '+%F %T'`
  if [[ -e "${script_path}/ft_config/ft_config_narration.on" ]]
  then  
    echo "   Debug: $@" 
  fi
  
  if [[ -e "${script_path}/ft_config/ft_config_logging.on" ]]
  then
    # Bugfix R207 - Add -e & \r to generate a carrage return for Windows' Notepad
    echo -e "(${log_timestamp}): ${@}\r" >> ${debug_path}${debug_filename}
  fi
  
  if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]
  then
    echo -e "(${log_timestamp}): ${@}\r" >> ${debug_path}${debug_filename}.trace.log
  fi  
}

# Trim the logfile if it gets too big
trim_log()
{
  log_size=`stat -c %s ${debug_path}${debug_filename}`   # Get Filesize
  if [ "${log_size}" -gt "${debug_logfile_maxsize}" ]; # if it gets too big...
  then
    echo "   Trimming log... ( ${log_size} bytes )"

    # Compress the old logfile
    echo "   Compressing old log..."
    compress_gzip_file ${debug_path}${debug_filename}
  else
    echo "   Log does not need trimming. ( ${log_size} bytes )"
  fi
}

# Simple little append logger and console dumper
# Output debug information to console
debug_console_output="N"
# Output debug information to trace file
debug_tracefile_output="Y"
# Logs over 100KB are automatically gzipped.
debug_logfile_maxsize=100000
# Path to write tracefile logs to
debug_path="${script_path}/ft_logs/"
# Define the logfilename backup 'generic' date format: YYYYMMDD_HHMMSS
debug_file_date=`date +%Y%0m%0d_%0H%0M%0S`
# This is the default log file name if a task does not redefine it.
debug_filename="filetasker.log"
debug_out()
{
  if [ ${debug_console_output} == "Y" ] 
  then  
    echo "   Debug: $@" 
  fi
  if [ ${debug_tracefile_output} == "Y" ]
  then
    # Bugfix R207 - Add -e to echo to enable escapes
    # Bugfix R207 - Add \r to generate a carrage return for Windows' Notepad
    echo -e "("`date '+%F %T'`"): ${@}\r" >> ${debug_path}${debug_filename}
  fi
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
  debug_out "  Trapped Signal ${1} (${2}), bailing out..."
  echo "  Trapped Signal ${1} (${2}), bailing out..."
  debug_dump_output=Y
  quit_filetasker
  exit 0
}

# Debugging variable dumpers
trap_debug_dump()
{
    echo "Call Stack:" ${FUNCNAME[@]}
    debug_out "Call Stack:" ${FUNCNAME[@]}
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
    trap_debug_task_dump
  fi
}

# Override this in the task
trap_debug_task_dump()
{
  :;
}
# End Debugging functions



# Start Main Routines
# Default task_init function. Override me.
task_init_hook() { :; }
task_init()
{
  echo "  Loaded taskfile ${task_name} at ${SECONDS} seconds."
  task_init_hook
}

# Selects a subtask to perform.
# Choices are currently: link, copy, move, debug
# noclobber is the default mode.
select_subtask()
{
  debug_out "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME} "with ${#@} params:" ${@}
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
  echo "   Selected subtask is: ${selected_subtask}"
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
  echo "  Traversing to Source Directory at ${SECONDS} seconds..."
  # Is the source path a directory?
  if [ -d ${source_path} ]
  then
    # Yes, it's a directory, descend into it.
    cd ${source_path}
  else
    # Wasn't a directory.
    echo "FATAL: Cannot find Taskfile's Source Directory ${source_path}"
    exit ${E_MISSINGFILE}; # Throw an error
  fi
  echo "  Searching Source directory ${PWD}/ for ${file_ext} files"
}

# Change directories back to the previous working directory
quit_filetasker()
{
  # Head Home
  echo "  Traversing back to Script Directory..."
  cd ${script_path}
  # Log too big?
  echo "  Trimming log (If needed)..."
  # Close the log, show our times, then trim the log (Prevents leaving a one-line log after gz)
  debug_out "LOG SECTION END -- Script took ${SECONDS} seconds to complete all operations."
  trim_log
  echo " Script took ${SECONDS} seconds to execute."
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
echo "  FileTasker Common Operations Module ${ftask_version} Loaded at ${SECONDS} seconds."
# -----------
# End Main Program
# -----------
