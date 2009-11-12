# -----------
# FileTasker File Matching Script
# -----------
# CMDLine Inputs: NIL (Not Executable)
# -----------
# Common Operations Functions
# Sourced by ft_file_core.sh
# -----------
# End Program Information
# -----------

# -----------
# Variable Defaults
# -----------

# -----------
# Error Codes
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

# -----------
# File Match Functions
# -----------

# Start Sub Routines

# How long should match sleep?
# Inputs: ${1} seconds to sleep
match_sleep() 
{ 
  if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then
  message_output ${MSG_TRACE} "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME[@]} "with ${#@} params:" ${@}; fi
  if [[ -e "${script_path}/ft_config/ft_config_match_sleep.off" ]]; then
    message_output ${MSG_NOTICE} " File Match - Skipping Match Sleep"
  else
    sleep ${1}; 
  fi
  return 0;
}

files_match()
{
  if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then
  message_output ${MSG_TRACE} "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME[@]} "with ${#@} params:" ${@}; fi
  local myvar=`match_check_snapshot ${file_name}`;
  message_output ${MSG_NOTICE} " File Match - COMPAT MATCHING FILES NOW ${myvar}"
  return $myvar;
}

# Take a snapshot of file metadata for matching
# Inputs: ${1} Filename
match_take_snapshot()
{
  if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then
  message_output ${MSG_TRACE} "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME[@]} "with ${#@} params:" ${@}; fi
  message_output ${MSG_INFO} " File Match - Snapshotting Sourcefile Metadata"
  file_size=`stat -c %s ${1}`   # Get Filesize
  file_mtime=`stat -c %Y ${1}`   # Get Last Written To in Epoch
}

# Check against our last snapshot
# Inputs: ${1} Filename
# Outputs: 0 on success, 1 on fail, -1 on nonexistant
match_check_snapshot() 
{
  if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then
  message_output ${MSG_TRACE} "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME[@]} "with ${#@} params:" ${@}; fi
  message_output ${MSG_INFO} " File Match - Verifying Match"
  match_sleep 2; # Snooze for a couple seconds, waiting for mtimes to change?
  if [[ -e ${1} ]]; then # If file still exists
    file_size_new=`stat -c %s ${1}`   # Get Filesize
    file_mtime_new=`stat -c %Y ${1}`   # Get Last Written To in Epoch
    if match_files; then # Check to see if they match
        message_output ${MSG_NOTICE} "  File [MATCH] -- Operation Proceeding!"
        return 0;
      else
        message_output ${MSG_ERROR} "  File [MISMATCH] -- SKIPPING THIS FILE"
        return 1; # Bail out
    fi 
  else
    message_output ${MSG_ERROR} "  File [MISSING] -- SKIPPING THIS FILE"
    return -1; # Bail out early
  fi
}

match_files()
{
  if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then
  message_output ${MSG_TRACE} "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME[@]} "with ${#@} params:" ${@}; fi
  if [[ "${file_size}" -eq "${file_size_new}" ]];
    then
      message_output ${MSG_NOTICE} "  File [MATCH] Size was: ${file_size} now: ${file_size_new}"
      if [[ "${file_mtime}" -eq "${file_mtime_new}" ]];
        then
          message_output ${MSG_NOTICE} "  File [MATCH] mTime was: ${file_mtime} now: ${file_mtime_new}"
          return 0; # Success
        else
          message_output ${MSG_ERROR} "  File [MISMATCH] mTime was: ${file_mtime} now: ${file_mtime_new}"
          return ${E_MISMATCH};
      fi
    else
    message_output ${MSG_ERROR} "  File [MISMATCH] Size was: ${file_size} now: ${file_size_new}"
    return ${E_MISMATCH};
  fi
}

# End Sub Routines

# -----------
# End Functions
# -----------

# -----------
# Main Program
# -----------

# Output Loader information
if [[ -e "${script_path}/ft_config/ft_config_verbose.on" ]]; then
  echo "  FileTasker File Matching Module ${ftask_version} Loaded at ${SECONDS} seconds."; fi
# -----------
# End Main Program
# -----------
