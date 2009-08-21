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
  gzip ${compress_flags:='-9'} ${1}
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
  mv ${move_flags:='-u'} ${1} ${2}
  move_file_post ${1} ${2}
}

# Hooks for pre and post operations
copy_file_pre () { :; }
copy_file_post () { :; }
copy_file()
{
  copy_file_pre ${1} ${2}
  echo -e "    Copying" ${1} "\n    to" ${2}
  cp ${copy_flags:='-u'} ${1} ${2}
  copy_file_post ${1} ${2}
}

# Hooks for pre and post operations
link_file_pre () { :; }
link_file_post () { :; }
link_file()
{
  link_file_pre ${1} ${2}
  echo -e "    Linking" ${1} "\n    to" ${2}
  cp  ${link_flags:='-su'} ${1} ${2}
  link_file_post ${1} ${2}
}

# Hooks for pre and post operations
debug_file_pre () { :; }
debug_file_post () { :; }
debug_file()
{
  debug_file_pre ${1} ${2}
  echo "    -------------"
  debug_out "  Old Filepath: ${source_path}"  
  echo "    Old Filepath: ${source_path}"  
  debug_out "  Old Filename: `basename ${1}`"
  echo "    Old Filename: `basename ${1}`"
  debug_out "  New Filepath: ${target_path}"
  echo "    New Filepath: ${target_path}"
  debug_out "  New Filename: `basename ${2}`"
  echo "    New Filename: `basename ${2}`"
  debug_file_post ${1} ${2}
}

# Dummy fileop function
perform_fileop()
{
  debug_out "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME} "with ${#@} params:" ${@}
  # Perform the selected file operation
  debug_out " Performing subtask: ${1}"
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
}

# Pathname Parser
parse_pathname_pre () { :; }
parse_pathname_post () { :; }
# Convert / to space delimited array
parse_pathname()
{
  debug_out "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME} "with ${#@} params:" ${@}
  parse_pathname_pre ${@}
  ar_path_name=( $( echo ${1} | tr \'${parse_seperator:-"/"}\' ' ' ) )
  debug_out " Parsed Pathname: ${#ar_path_name[@]} elements:" ${ar_path_name[@]}
  parse_pathname_post ${ar_path_name}
}

# Filename Parser
parse_filename_pre () { :; }
parse_filename_post () { :; }
# Convert . to space delimited array
parse_filename()
{
  debug_out "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME} "with ${#@} params:" ${@}
  parse_filename_pre ${@}
  ar_file_name=( $( echo ${1} | tr \'${parse_seperator:-"."}\' ' ' ) )
  debug_out " Parsed Filename: ${#ar_file_name[@]} elements:" ${ar_file_name[@]}
  parse_filename_post ${ar_file_name}
}

# Filename Builder
build_filename_pre () { :; }
build_filename_post () { :; }
# Convert array to filename
build_filename()
{
  debug_out "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME} "with ${#@} params:" ${@}
  build_filename_pre ${ar_file_name[@]}
  # Set up our locals
  local my_ar_file_name=${ar_file_name[@]}
  local my_output_file_name
  # Iterate over array and rebuild new filename
  for name_element in ${my_ar_file_name[@]}
    do
      my_output_file_name+=".${name_element}"
    done
  # Copy the new string to a real variable and strip off the leading "."
  new_file_name=${my_output_file_name:1}
  build_filename_post ${new_file_name}
}

# Our working directory is already set by the time this is called.
# Called once for each working directory
iterate_files()
{
  debug_out "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME} "with ${#@} params:" ${@}
  # Gather filenames into array
  filenames=( `ls -1t | grep "${file_ext}" | tr '\n' ' '` )
  echo  "   Found ${#filenames[@]} ${file_ext} files in ${PWD}/"

  # Iterate over filenames array
  for file_name in ${filenames[@]}
    do
      # Is this truly a file?
      if [ -e "${file_name}" ]; then
        # Yes, it's a file. Snapshot the old name, and call the task.
        debug_out " FOUND A FILE: ${file_name}"
        orig_file_name=${file_name}
        task ${file_name}
      fi
    done
  echo  "   Completed operations on ${#filenames[@]} ${file_ext} files"
}

iterate_directories()
{
  debug_out "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME} "with ${#@} params:" ${@}
  if [ ${ft_multidir} ]; then
    echo "    Searching Multiple Source Directories."
    gather_directories
    # DIRSTACK starts out with a useless entry to ".", we'll just stop at 1.
    # Otherwise this would read: for dir_name in ${DIRSTACK[@]}
    while [ "${#DIRSTACK[@]}" -gt "1" ]
      do
        debug_out "Directory Stack Contents (${#DIRSTACK[@]}): ${DIRSTACK[@]}."
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
  debug_out "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME} "with ${#@} params:" ${@}
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
      if [ -d "${directory_name}" ]; then
        debug_out " FOUND A DIRECTORY:" `readlink -f ${directory_name}`
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

files_match()
{
  debug_out "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME} "with ${#@} params:" ${@}
  if [ "${file_size}" -eq "${file_size_new}" ];
    then
      debug_out " File Size [MATCH] was: ${file_size} now: ${file_size_new}"
      if [ "${file_mtime}" -eq "${file_mtime_new}" ];
        then
          debug_out " File mTime [MATCH] was: ${file_mtime} now: ${file_mtime_new}"
          return 0; # Success
        else
          debug_out " File mTime [MISMATCH] was: ${file_mtime} now: ${file_mtime_new}"
          return ${E_MISMATCH};
      fi
    else
    debug_out " File Size [MISMATCH] was: ${file_size} now: ${file_size_new}"
    return ${E_MISMATCH};
  fi
}

check_and_compress_gzip_file()
{
  debug_out "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME} "with ${#@} params:" ${@}
  local my_filename=${1}
  local is_gzip_ext=${my_filename:(-3)}  # Capture the last three characters of the filename
  if [ "${is_gzip_ext}" == ".gz" ];
    then
      debug_out " File is already compressed with gzip." # We're already gzipped.
    else
      debug_out " File not compressed. Compressing with gzip..."
      compress_gzip_file ${target_path}${1} # Compress the file.
  fi
}

check_and_decompress_gzip_file()
{
  debug_out "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME} "with ${#@} params:" ${@}
  local my_filename=${1}
  local is_gzip_ext=${my_filename:(-3)}  # Capture the last three characters of the filename
  if [ "${is_gzip_ext}" == ".gz" ];
    then
      debug_out " File is compressed with gzip. Decompressing..." # We're already gzipped.
      decompress_gzip_file ${target_path}${1} # Decompress the file.
    else
      debug_out " File is already uncompressed."
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
echo "  FileTasker File Operations Module ${ftask_version} Loaded at ${SECONDS} seconds."
# -----------
# End Main Program
# -----------
