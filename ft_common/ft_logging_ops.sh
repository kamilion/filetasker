# -----------
# FileTasker Common Logging Operations Script
# -----------
# CMDLine Inputs: NIL (Not Executable)
# -----------
# Common Logging Operations Functions
# Sourced by ft_logging_core.sh
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
MSG_TRACE=20;    # Trace messages.
MSG_NOTICE=10;   # Notice messages.
MSG_STATUS=7;    # Status messages.
MSG_INFO=5;      # Informational messages.
MSG_VERBOSE=4;   # "Verbose" console.
MSG_CONSOLE=3;   # "Normal" console.
MSG_CRITICAL=2;  # Critical failure. Bailout imminant.
MSG_ERROR=1;     # Error messages.

# Translates numeric severity codes to human-readable names.
sev_name() # Meant to be called via backticks.
{ # Inputs: $1 - Numeric Severity Code
  case "${1}" in
  "1" )
    echo "   ERROR";
  ;;
  "2" )
    echo "CRITICAL";
  ;;
  "3" )
    echo " CONSOLE";
  ;;
  "4" )
    echo " VERBOSE";
  ;;
  "5" )
    echo "    INFO";
  ;;
  "7" )
    echo "  STATUS";
  ;;
  "10" )
    echo "  NOTICE";
  ;;
  "20" )
    echo "   TRACE";
  ;;
  * )
    # Default to UNKNOWN
    echo "  UNKNOWN";
  ;;
  esac
}

# Signal Traps
set_traps()
{ # Inputs: NIL
  # Set trap for signal DEBUG (DEBUG)
  #trap "trap_debug_dump" DEBUG
  # Set trap for signal 0 (EXIT)
  trap "trap_exit_dump" EXIT;
  # Set trap for signal 1 (HUP)
  trap "trap_bail_out 1 HANGUP" SIGHUP;
  # Set trap for signal 2 (QUIT)
  trap "trap_bail_out 2 QUIT" SIGQUIT;
  # Set trap for signal 3 (INT)
  trap "trap_bail_out 3 INTERRUPT" SIGINT;
  # Set trap for signal 15 (TERM)
  trap "trap_bail_out 15 TERM" SIGTERM;
  # Display all set traps
  #trap -p
}

# Called when a set trap is triggered.
debug_dump_output=N;
trap_bail_out()
{ # Inputs: $1 - Signal number, $2 - Signal Name
  message_output ${MSG_CRITICAL} "  Trapped Signal ${1} (${2}), bailing out...";
  message_output ${MSG_CRITICAL} "  Trapped Current File Name:" ${file_name};
  message_output ${MSG_CRITICAL} "  Trapped Call Stack:" ${FUNCNAME[@]};
  echo "  Trapped Signal ${1} (${2}), bailing out...";
  debug_dump_output=Y;
  quit_filetasker;
  exit 0;
}

# Dumps the function call stack.
trap_debug_dump()
{ # Inputs: NIL 
    echo "Call Stack:" ${FUNCNAME[@]};
    message_output ${MSG_TRACE} "Call Stack:" ${FUNCNAME[@]};
}

# Dumps debugging information when a trap occurs.
trap_exit_dump()
{  # Inputs: NIL
  if [[ ${debug_dump_output} == "Y" ]]
  then
    echo "Debug Dump in progress...";
    echo "dump_debug_message:" ${FUNCNAME[@]};
    echo "   Script Location:" ${script_location};
    echo "       Script Path:" ${script_path};
    echo "  Main Path Prefix:" ${main_path_prefix};
    echo "Source Path Prefix:" ${source_path_prefix};
    echo "       Source Path:" ${source_path};
    echo "Target Path Prefix:" ${target_path_prefix};
    echo "       Target Path:" ${target_path};
    echo "           FT_Args:" ${ft_args[*]};
    echo "         Task Name:" ${task_name};
    echo "      Subtask Name:" ${subtask_name};
    echo " Current File Name:" ${file_name};
    trap_debug_task_dump;
  fi
}

# Need some more information while debugging a task?
# Override this in the task, and ctrl-c while executing.
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
  echo "  FileTasker Common Logging Module Loaded at ${SECONDS} seconds."; fi
# -----------
# End Main Program
# -----------
