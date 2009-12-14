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
  logfile_filename="${task_name}"; # Set Default Logfile name
  add_logfile_to_trimlist "${logfile_filename}"; # Add it to the trimlist
  logfile_tracename="${task_name}"; # Set Default Tracefile name
  task_init_hook; # Task init hooks can change the log filename.
  message_output ${MSG_VERBOSE} "Loaded and Initialized taskfile ${task_name} at ${SECONDS} seconds.";
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
  if [[ -f "${task_file}" ]]
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

# Chains many tasks/tools in parallel
chain_multi()
{ # Input: $1 - Name of Array containing chain commands
  set -x
  local input="$1[@]" # Indirection trick, add array selector BEFORE indirection.
  local ar_input=${!input} # Now we can use variable indirection on array data like "input[*]"!
    echo ${#ar_input[@]};
  for element in ${ar_input[@]}; do # Because ${!input[*]} means list "array keys", not "array data"!
    echo $element;
  done
  set +x
}

# Chains a new instance of Filetasker and waits for it's completion
chain_task()
{ # Input: $1 - Task, $2 - Subtask, $3 - Additional Parameters
  if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then
  message_output ${MSG_TRACE} "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME[@]} "with ${#@} params:" ${@}; fi
  if [[ -e "${script_path}/ft_config/ft_config_chain.on" ]]; then
    message_output ${MSG_VERBOSE} "Task chaining - executing task: ${@}"
    ${script_path}/filetasker.sh ${@} & # Execute another filetasker in the background
    wait; # for background filetasker job to complete
    returnval=$?
    if [[ $returnval -eq "0" ]]; then
      return 0;
    else
      return $returnval;
    fi
  else
    message_output ${MSG_VERBOSE} "Task chaining disabled, will not execute task: ${@}"
  fi
}

# Chains a tool and waits for it's completion
chain_tool()
{ # Input: $1 - Tool cmdline
  if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then
  message_output ${MSG_TRACE} "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME[@]} "with ${#@} params:" ${@}; fi
  if [[ -e "${script_path}/ft_config/ft_config_chain.on" ]]; then
    message_output ${MSG_VERBOSE} "Task chaining - executing task: ${@}"
    ${@} & # Execute tool in the background
    wait; # for background job to complete
    returnval=$?
    if [[ $returnval -eq "0" ]]; then
      return 0;
    else
      return $returnval;
    fi
  else
    message_output ${MSG_VERBOSE} "Task chaining disabled, will not execute task: ${@}"
  fi
}

# Change directories to File Source Path
start_filetasker()
{
  message_output ${MSG_VERBOSE} "Working within Base Directory ${main_path_prefix}"
  message_output ${MSG_VERBOSE} "Traversing to Source Directory at ${SECONDS} seconds..."
  # Is the source path a directory?
  if [[ -d ${source_path} ]]
  then
    # Yes, it's a directory, descend into it.
    cd ${source_path}
  else
    # Wasn't a directory.
    message_output ${MSG_CONSOLE} "FATAL: Cannot find Taskfile's Source Directory ${source_path}"
    exit ${E_MISSINGFILE}; # Throw an error
  fi
  message_output ${MSG_VERBOSE} "Searching Source directory ${PWD#${main_path_prefix}}/ for ${file_ext} files"
}

# Change directories back to the previous working directory
quit_filetasker()
{
  # Head Home
  message_output ${MSG_VERBOSE} "Traversing back to Script Directory..."
  cd ${script_path}
  # Log too big?
  message_output ${MSG_VERBOSE} "Trimming log (If needed)...";
  # Close the log, show our times, then trim the log (Prevents leaving a one-line log after gz)
  message_output ${MSG_STATUS} "LOG SECTION END -- Script took ${SECONDS} seconds to complete all operations."
  trim_logs
  echo ""
}

COMMENTBLOCK() { :; } # Makes things easy to comment out.

#Dummy functions to override from Taskfiles
task_pre() { :; } # Called manually from beginning of task()
task_post() { :; } # Called manually at end of task()
task_subtask() { :; } # Defined for special tasks
task() { :; } # Called automatically by iterate_files()
task_directory_complete() { :; } # Called once automatically at the end of iterate_files() loop, $PWD as $1
task_complete() { :; } # Called once automatically at the end of iterate_directories(), No Inputs
task_multidir_pre() { :; } # Called automatically before directory pop
task_multidir_info() { :; } # Called automatically after directory pop, before iterate_files()
task_multidir_post() { :; } # Called automatically after iterate_files() completes
# End Main Routines

# -----------
# File Functions
# -----------

# Load Logging Operation Functions First
source ${script_path}/ft_common/ft_logging_ops.sh

# Load File Core Functions
source ${script_path}/ft_common/ft_file_core.sh

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
if [[ -e "${script_path}/ft_config/ft_config_verbose.on" ]]; then
  echo "  FileTasker Common Operations Module Loaded at ${SECONDS} seconds."; fi
# -----------
# End Main Program
# -----------
