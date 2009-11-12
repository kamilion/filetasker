# -----------
# FileTasker File Operations Script
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
# File Operation Functions
# -----------

# Hooks for pre and post operations
move_file_pre () { :; }
move_file_post () { :; }
move_file()
{
  move_file_pre ${1} ${2}
  local returnval=$?
  message_output ${MSG_VERBOSE} "  Moving" ${1#${main_path_prefix}}
  message_output ${MSG_VERBOSE} "  to" ${2#${main_path_prefix}}
  if [[ -e ${2} ]]; then
    # Yes, it exists.
    if [[ -h ${2} ]]; then
      # It's a link. Clobber/update it.
      message_output ${MSG_STATUS} "  Target link already exists. Overwriting Link with File."
      rm ${2}
      mv ${move_flags:='-f'} ${1} ${2}
      returnval=$?
    else
      # It's not a link. Clobber/Move over it.
      message_output ${MSG_STATUS} "  Target file already exists. Moving file with Overwrite."
      rm ${2}
      mv ${move_flags:='-f'} ${1} ${2}
      returnval=$?
    fi
  else
    # No existing file. Make one.
    message_output ${MSG_STATUS} "  Target does not exist. Creating file."
    mv ${move_flags:='-f'} ${1} ${2}
    returnval=$?
  fi
  move_file_post ${1} ${2}
  return $returnval;
}

# Hooks for pre and post operations
copy_file_pre () { :; }
copy_file_post () { :; }
copy_file()
{
  copy_file_pre ${1} ${2}
  local returnval=$?
  message_output ${MSG_VERBOSE} "  Copying" ${1#${main_path_prefix}}
  message_output ${MSG_VERBOSE} "  to" ${2#${main_path_prefix}}
  if [[ -e ${2} ]]; then
    # Yes, it exists.
    if [[ -h ${2} ]]; then
      # It's a link. Clobber/update it.
      message_output ${MSG_STATUS} "  Target link already exists. Overwriting."
      rm ${2}
      cp ${copy_flags:="-f"} ${1} ${2}
      returnval=$?
    else
      # It's not a link. Don't clobber existing files during copy.
      message_output ${MSG_STATUS} "  Target file already exists. Keeping existing."
      return $E_FILEEXISTS;
    fi
  else
    # No existing file. Make one.
    message_output ${MSG_STATUS} "  Target does not exist. Creating file."
    cp ${copy_flags:='-f'} ${1} ${2}
    returnval=$?
  fi
  copy_file_post ${1} ${2}
  return $returnval;
}

# Hooks for pre and post operations
link_file_pre () { :; }
link_file_post () { :; }
link_file()
{
  link_file_pre ${1} ${2}
  local returnval=$?
  message_output ${MSG_VERBOSE} "  Linking" ${1#${main_path_prefix}}
  message_output ${MSG_VERBOSE} "  to" ${2#${main_path_prefix}}
  if [[ -e ${2} ]]; then
    # Yes, it exists.
    if [[ -h ${2} ]]; then
      # It's a link. Clobber/update it.
      message_output ${MSG_STATUS} "  Target link already exists. Overwriting link."
      ln  ${link_flags:='-sf'} ${1} ${2}
      returnval=$?
    else
      # It's not a link. Don't clobber it.
      message_output ${MSG_STATUS} "  Target file already exists. Keeping existing."
      return $E_FILEEXISTS;
    fi
  else
    # No existing link. Make one.
    message_output ${MSG_STATUS} "  Target does not exist. Creating link."
    ln  ${link_flags:='-sf'} ${1} ${2}
    returnval=$?
  fi
  link_file_post ${1} ${2}
  return $returnval;
}

# Hooks for pre and post operations
debug_file_pre () { :; }
debug_file_post () { :; }
debug_file()
{
  debug_file_pre ${1} ${2}
  message_output ${MSG_CONSOLE} "  -------------"
  message_output ${MSG_CONSOLE} "  Old Filepath: ${source_path#${main_path_prefix}}"  
  message_output ${MSG_CONSOLE} "  Old Filename: `basename ${1}`"
  message_output ${MSG_CONSOLE} "  New Filepath: ${target_path#${main_path_prefix}}"
  message_output ${MSG_CONSOLE} "  New Filename: `basename ${2}`"
  debug_file_post ${1} ${2}
  return 0;
}

perform_fileop_post() { :; }
# Dummy fileop function
perform_fileop()
{
  if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then
  message_output ${MSG_TRACE} "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME[@]} "with ${#@} params:" ${@}; fi
  # Update the linklist paths if that feature is enabled.
  if [[ -e "${script_path}/ft_config/ft_config_gen_filelist.on" ]]; then update_linklist_paths; fi
  # Check and create our target directories
  generate_dir ${target_path}
  # Perform the selected file operation
  message_output ${MSG_INFO} " Performing subtask: ${1}"
  local returnval=$?
  case "${1}" in
  "link" )
    link_file ${source_path}${2} ${target_path}${3}
    returnval=$?
  ;;
  "copy" )
    copy_file ${source_path}${2} ${target_path}${3}
    returnval=$?
  ;;
  "move" )
    move_file ${source_path}${2} ${target_path}${3}
    returnval=$?
  ;;
  * )
    # Undefined fileop, just debug.
    debug_file ${source_path}${2} ${target_path}${3}
    returnval=$?
  ;;
  esac
  # Post operation work
  if [[ $ft_output_compression == "gzip" ]]; # Is compression on?
    then # We need to handle filename changes from compression
      check_and_compress_gzip_file ${3}; # Run the compressor
      if [[ $? -eq "1"  ]]; # Did the filename change? (-1)
        then perform_fileop_post "${3}.gz"; # Filename did change, append gz.
        else perform_fileop_post ${3}; # Filename did not change, pass on unchanged.
      fi
    else # Compression is off
      perform_fileop_post ${3}; # Compression is off, filename did not change.
      update_linklist ${3}; # Disabling compression bypasses the linklist hook there.
  fi
  if [[ $returnval -eq "0" ]]; then
    ((filenames_count_success++))
    message_output ${MSG_STATUS} " File Operation Successful (${returnval}) for ${3}"
  else
    ((filenames_count_failure++))
    message_output ${MSG_ERROR} " File Operation Failed (${returnval}) for ${3}"
  fi
  return $returnval;
}

# Start Sub Routines

# Linklist operations
add_to_linklist() { echo ${target_path}${1} >> ${logfile_path}${logfile_date}.${logfile_filename}.filelist.log; }
add_to_linkdir() { ln -sf ${target_path}${1} ${linkdir_path}; }
update_linklist()
{
  if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then
  message_output ${MSG_TRACE} "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME[@]} "with ${#@} params:" ${@}; fi
  if [[ -e "${script_path}/ft_config/ft_config_gen_linkdir.on" ]]; then
    message_output ${MSG_NOTICE} "  LinkList: Now linking ${1} to ${linkdir_path}" 
    add_to_linkdir ${1} # Add the link to the linkdir if linklist is on.
  fi
  if [[ -e "${script_path}/ft_config/ft_config_gen_filelist.on" ]]; then 
    message_output ${MSG_NOTICE} "  LinkList: Now adding ${1} to list" 
    add_to_linklist ${1} # This should always happen even if linklist is off, if filelist is on.
  fi
}
# Updates the variables during a running task
update_linklist_paths()
{
  if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then
  message_output ${MSG_TRACE} "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME[@]} "with ${#@} params:" ${@}; fi
  linkdir_path="${target_base_path}linkdir/";
  generate_dir ${linkdir_path}
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
  echo "  FileTasker File Operations Module ${ftask_version} Loaded at ${SECONDS} seconds."; fi
# -----------
# End Main Program
# -----------
