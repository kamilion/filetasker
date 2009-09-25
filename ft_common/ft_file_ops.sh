# -----------
# FileTasker File Operations Script
# -----------
# CMDLine Inputs: NIL (Not Executable)
# -----------
# Common Operations Functions
# Sourced by ft_common_ops.sh
# -----------
# End Program Information
# -----------

# -----------
# Variable Defaults
# -----------

# -----------
# Error Codes
# -----------

E_MISSINGFILE=66 # Couldn't find a file
E_MISMATCH=67 # File size/mtime didn't match

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

# Quiet down pushd and popd
pushd() { builtin pushd "${@}" > /dev/null; }
popd() { builtin popd "${@}" > /dev/null; }

# -----------
# File Functions
# -----------

# Hooks for pre and post operations
tar_file_pre () { :; }
tar_file_post () { :; }
tar_file ()
{
  tar_file_pre ${1}
  echo "    Tarring" ${1}
  tar ${tar_flags:='-cvf'} ${1}
  tar_file_post ${1}
}

# Hooks for pre and post operations
untar_file_pre () { :; }
untar_file_post () { :; }
untar_file ()
{
  untar_file_pre ${1}
  echo "    Untarring" ${1}
  tar ${untar_flags:='-xvf'} ${1}
  untar_file_post ${1}
}

# Hooks for pre and post operations
compress_gzip_file_pre () { :; }
compress_gzip_file_post () { :; }
compress_gzip_file ()
{
  compress_gzip_file_pre ${1}
  echo "    Compressing" ${1}
  gzip ${compress_flags:='-9f'} ${1}
  compress_gzip_file_post ${1}
}

# Hooks for pre and post operations
decompress_gzip_file_pre () { :; }
decompress_gzip_file_post () { :; }
decompress_gzip_file ()
{
  decompress_gzip_file_pre ${1}
  echo "    Decompressing" ${1}
  gzip ${decompress_flags:='-vd'} ${1}
  decompress_gzip_file_post ${1}
}

# Hooks for pre and post operations
move_file_pre () { :; }
move_file_post () { :; }
move_file()
{
  move_file_pre ${1} ${2}
  echo -e "    Moving" ${1} "\n    to" ${2}
  if [[ -e ${2} ]]; then
    # Yes, it exists.
    if [[ -h ${2} ]]; then
      # It's a link. Clobber/update it.
      message_output ${MSG_STATUS} "  Target link already exists. Overwriting Link with File."
      rm ${2}
      mv ${move_flags:='-f'} ${1} ${2}
    else
      # It's not a link. Clobber/Move over it.
      message_output ${MSG_STATUS} "  Target file already exists. Moving file with Overwrite."
      rm ${2}
      mv ${move_flags:='-f'} ${1} ${2}
    fi
  else
    # No existing file. Make one.
    message_output ${MSG_STATUS} "  Target does not exist. Creating file."
    mv ${move_flags:='-f'} ${1} ${2}
  fi
  move_file_post ${1} ${2}
}

# Hooks for pre and post operations
copy_file_pre () { :; }
copy_file_post () { :; }
copy_file()
{
  copy_file_pre ${1} ${2}
  echo -e "    Copying" ${1} "\n    to" ${2}
  if [[ -e ${2} ]]; then
    # Yes, it exists.
    if [[ -h ${2} ]]; then
      # It's a link. Clobber/update it.
      message_output ${MSG_STATUS} "  Target link already exists. Overwriting."
      rm ${2}
      cp ${copy_flags:="-f"} ${1} ${2}
    else
      # It's not a link. Don't clobber existing files during copy.
      message_output ${MSG_STATUS} "  Target file already exists. Keeping existing."
      return;
    fi
  else
    # No existing file. Make one.
    message_output ${MSG_STATUS} "  Target does not exist. Creating file."
    cp ${copy_flags:='-f'} ${1} ${2}
  fi
  copy_file_post ${1} ${2}
}

# Hooks for pre and post operations
link_file_pre () { :; }
link_file_post () { :; }
link_file()
{
  link_file_pre ${1} ${2}
  echo -e "    Linking" ${1} "\n    to" ${2}
  if [[ -e ${2} ]]; then
    # Yes, it exists.
    if [[ -h ${2} ]]; then
      # It's a link. Clobber/update it.
      message_output ${MSG_STATUS} "  Target link already exists. Overwriting link."
      ln  ${link_flags:='-sf'} ${1} ${2}
    else
      # It's not a link. Don't clobber it.
      message_output ${MSG_STATUS} "  Target file already exists. Keeping existing."
      return;
    fi
  else
    # No existing link. Make one.
    message_output ${MSG_STATUS} "  Target does not exist. Creating link."
    ln  ${link_flags:='-sf'} ${1} ${2}
  fi
  link_file_post ${1} ${2}
}

# Hooks for pre and post operations
debug_file_pre () { :; }
debug_file_post () { :; }
debug_file()
{
  debug_file_pre ${1} ${2}
  echo "    -------------"
  message_output ${MSG_INFO} "  Old Filepath: ${source_path}"  
  echo "    Old Filepath: ${source_path}"  
  message_output ${MSG_INFO} "  Old Filename: `basename ${1}`"
  echo "    Old Filename: `basename ${1}`"
  message_output ${MSG_INFO} "  New Filepath: ${target_path}"
  echo "    New Filepath: ${target_path}"
  message_output ${MSG_INFO} "  New Filename: `basename ${2}`"
  echo "    New Filename: `basename ${2}`"
  debug_file_post ${1} ${2}
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
  check_and_create_target_dirs
  # Perform the selected file operation
  message_output ${MSG_INFO} " Performing subtask: ${1}"
  case "${1}" in
  "link" )
    link_file ${source_path}${2} ${target_path}${3}
  ;;
  "copy" )
    copy_file ${source_path}${2} ${target_path}${3}
  ;;
  "move" )
    move_file ${source_path}${2} ${target_path}${3}
  ;;
  * )
    # Undefined fileop, just debug.
    debug_file ${source_path}${2} ${target_path}${3}
  ;;
  esac
  # Post operation work
  if [[ $ft_output_compression == "gzip" ]]; # Is compression on?
    then # We need to handle filename changes from compression
      check_and_compress_gzip_file ${3}; # Run the compressor
      if [[ $? -eq "-1"  ]]; # Did the filename change? (-1)
        then perform_fileop_post "${3}.gz"; # Filename did change, append gz.
        else perform_fileop_post ${3}; # Filename did not change, pass on unchanged.
      fi
    else # Compression is off
      perform_fileop_post ${3}; # Compression is off, filename did not change.
      update_linklist ${3}; # Disabling compression bypasses the linklist hook there.
  fi
}

# Pathname Parser
parse_pathname_pre () { :; }
parse_pathname_post () { :; }
# Convert / to space delimited array
parse_pathname()
{
  if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then
  message_output ${MSG_TRACE} "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME[@]} "with ${#@} params:" ${@}; fi
  parse_pathname_pre ${@}
  ar_path_name=( $( echo ${1} | tr \'${parse_seperator:-"/"}\' ' ' ) )
  message_output ${MSG_INFO} " Parsed Pathname: ${#ar_path_name[@]} elements:" ${ar_path_name[@]}
  parse_pathname_post ${ar_path_name}
}

# Filename Parser
parse_filename_pre () { :; }
parse_filename_post () { :; }
# Convert . to space delimited array
parse_filename()
{
  if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then
  message_output ${MSG_TRACE} "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME[@]} "with ${#@} params:" ${@}; fi
  parse_filename_pre ${@}
  ar_file_name=( $( echo ${1} | tr \'${parse_seperator:-"."}\' ' ' ) )
  message_output ${MSG_INFO} " Parsed Filename: ${#ar_file_name[@]} elements:" ${ar_file_name[@]}
  parse_filename_post ${ar_file_name}
}

# Filename Builder
build_filename_pre () { :; }
build_filename_post () { :; }
# Convert array to filename
build_filename()
{
  if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then
  message_output ${MSG_TRACE} "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME[@]} "with ${#@} params:" ${@}; fi
  build_filename_pre ${ar_file_name[@]}
  # Set up our locals
  local my_ar_file_name=${ar_file_name[@]}
  local my_output_file_name
  # Iterate over array and rebuild new filename
  for name_element in ${my_ar_file_name[@]}
    do
      my_output_file_name="${my_output_file_name}.${name_element}"
    done
  # Copy the new string to a real variable and strip off the leading "."
  new_file_name=${my_output_file_name:1}
  build_filename_post ${new_file_name}
}

# Our working directory is already set by the time this is called.
# Called once for each working directory
iterate_files()
{
  if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then
  message_output ${MSG_TRACE} "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME[@]} "with ${#@} params:" ${@}; fi
  # Gather filenames into array
  filenames=( `ls -1t | grep "${file_ext}" | tr '\n' ' '` )
  echo  "   Found ${#filenames[@]} ${file_ext} files in ${PWD}/"

  # Iterate over filenames array
  for file_name in ${filenames[@]}
    do
      # Is this truly a file?
      if [[ -e "${file_name}" ]]; then
        # Yes, it's a file. Snapshot the old name, and call the task.
        #message_output ${MSG_NOTICE} " FOUND A FILE: ${file_name}"
        orig_file_name=${file_name}
        task ${file_name}
      fi
    done
  echo  "   Completed operations on ${#filenames[@]} ${file_ext} files"
}

iterate_directories()
{
  if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then
  message_output ${MSG_TRACE} "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME[@]} "with ${#@} params:" ${@}; fi
  if [[ ${ft_multidir} ]]; then
    echo "    Searching Multiple Source Directories."
    gather_directories
    # DIRSTACK starts out with a useless entry to ".", we'll just stop at 1.
    # Otherwise this would read: for dir_name in ${DIRSTACK[@]}
    while [[ "${#DIRSTACK[@]}" -gt "1" ]]
      do
        message_output ${MSG_INFO} "Directory Stack Contents (${#DIRSTACK[@]}): ${DIRSTACK[@]}."
        popd
        dir_name=`basename ${PWD}/`
        echo "    Traversed to ${dir_name}"
        iterate_files
      done
    return 0; # Success
  else
    echo "    Searching Single Source Directory."
    iterate_files
    return 0; # Success
  fi
}

gather_directories()
{
  if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then
  message_output ${MSG_TRACE} "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME[@]} "with ${#@} params:" ${@}; fi
  IFS=$'\n'   # Enable for loops over items with spaces in their name
  # Magic Command to run to gather directory list
  local dirsource=`ls -1Ft | grep "/"`
  IFS=${OLDIFS}  # Restore IFS
  # Gather filenames into array
  local directory_names=( ${dirsource} )
  echo  "    Found ${#directory_names[@]} directories total."

  # Clear the directory stack once
  dirs -c

  # Iterate over directories array
  for directory_name in ${directory_names[@]}
    do
      # Is this entry a directory?
      if [[ -d "${directory_name}" ]]; then
        message_output ${MSG_INFO} " FOUND A DIRECTORY:" `readlink -f ${directory_name}`
        # Yep, it's a directory.
        # Add it to the Iterate list to discover the files inside.
        # NOTE: pushd -n will add to $DIRSTACK without changing $PWD.
        # NOTE: `readlink -f $dir` will expand the full path.
        pushd -n `readlink -f ${directory_name}`
      fi
    done
  echo  "   Completed discovery in ${#directory_names[@]} directories: ${directory_names[@]}"
}

# Start Sub Routines

# ALIAS: Generates the directories the links will be stored in
generate_dir() { mkdir -p ${1}; }

# How long should match sleep?
# Inputs: ${1} seconds to sleep
match_sleep() 
{ 
  if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then
  message_output ${MSG_TRACE} "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME[@]} "with ${#@} params:" ${@}; fi
  if [[ -e "${script_path}/ft_config/ft_config_turbo.on" ]]; then
    message_output ${MSG_NOTICE} " File Match - TURBO ENABLED - Skipping Match Sleep"
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

check_and_compress_gzip_file()
{
  if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then
  message_output ${MSG_TRACE} "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME[@]} "with ${#@} params:" ${@}; fi
  local my_filename=${1}
  local is_gzip_ext=${my_filename:(-3)}  # Capture the last three characters of the filename
  if [[ "${is_gzip_ext}" == ".gz" ]];
    then
      message_output ${MSG_STATUS} " File is already compressed with gzip." # We're already gzipped.
      if [[ "${selected_subtask}" != "debug" ]]; then # No targets to generate filelists or linklists in debug mode!
          if [[ -e "${script_path}/ft_config/ft_config_gen_filelist.on" ]]; then update_linklist ${1}; fi
      fi
      return 0; # Success, already compressed, don't change filename
    else
      message_output ${MSG_NOTICE} " File not compressed. Compressing with gzip..."
      if [[ "${selected_subtask}" != "debug" ]];
        then # Not debug mode, compress the file.
          compress_gzip_file ${target_path}${1} # Compress the file.
          if [[ -e "${script_path}/ft_config/ft_config_gen_filelist.on" ]]; then update_linklist "${1}.gz"; fi
          return -1; # Success, filename changed
        else # No need to do anything if we're in debug mode.
          message_output ${MSG_INFO} " Skipped compression, in debug mode."
          return 0; # Success, nothing done
      fi
      return 0; # Success, nothing done?
  fi
}

check_and_decompress_gzip_file()
{
  if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then
  message_output ${MSG_TRACE} "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME[@]} "with ${#@} params:" ${@}; fi
  local my_filename=${1}
  local is_gzip_ext=${my_filename:(-3)}  # Capture the last three characters of the filename
  if [[ "${is_gzip_ext}" == ".gz" ]];
    then
      message_output ${MSG_NOTICE} " File is compressed with gzip. Decompressing..." # We're already gzipped.
      decompress_gzip_file ${target_path}${1} # Decompress the file.
    else
      message_output ${MSG_INFO} " File is already uncompressed."
  fi
}

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
echo "  FileTasker File Operations Module ${ftask_version} Loaded at ${SECONDS} seconds."
# -----------
# End Main Program
# -----------
