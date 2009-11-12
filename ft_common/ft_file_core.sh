# -----------
# FileTasker File Core Script
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
E_FILEEXISTS=68 # A real file exists, should not link.

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

# ALIAS: Generates the directories the links will be stored in
generate_dir() { mkdir -p ${1}; }

# -----------
# File Functions
# -----------

# Pathname Parser
parse_pathname_pre () { :; }
parse_pathname_post () { :; }
# Convert / to space delimited array
parse_pathname()
{
  if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then
  message_output ${MSG_TRACE} "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME[@]} "with ${#@} params:" ${@}; fi
  parse_pathname_pre ${@};
  ar_path_name=( $( echo ${1} | tr \'${parse_seperator:-"/"}\' ' ' ) );
  message_output ${MSG_INFO} " Parsed Pathname: ${#ar_path_name[@]} elements:" ${ar_path_name[@]};
  parse_pathname_post ${ar_path_name};
}

# Filename Parser
parse_filename_pre () { :; }
parse_filename_post () { :; }
# Convert . to space delimited array
parse_filename()
{
  if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then
  message_output ${MSG_TRACE} "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME[@]} "with ${#@} params:" ${@}; fi
  parse_filename_pre ${@};
  ar_file_name=( $( echo ${1} | tr \'${parse_seperator:-"."}\' ' ' ) );
  message_output ${MSG_INFO} " Parsed Filename: ${#ar_file_name[@]} elements:" ${ar_file_name[@]};
  parse_filename_post ${ar_file_name};
}

# Filename Builder
build_filename_pre () { :; }
build_filename_post () { :; }
# Convert array to filename
build_filename()
{
  if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then
  message_output ${MSG_TRACE} "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME[@]} "with ${#@} params:" ${@}; fi
  build_filename_pre ${ar_file_name[@]};
  # Set up our locals
  local my_ar_file_name=${ar_file_name[@]};
  local my_output_file_name;
  # Iterate over array and rebuild new filename
  for name_element in ${my_ar_file_name[@]}
    do
      my_output_file_name="${my_output_file_name}.${name_element}";
    done
  # Copy the new string to a real variable and strip off the leading "."
  new_file_name=${my_output_file_name:1};
  build_filename_post ${new_file_name};
}

# Our working directory is already set by the time this is called.
# Called once for each working directory
iterate_files()
{
  if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then
  message_output ${MSG_TRACE} "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME[@]} "with ${#@} params:" ${@}; fi
  # Gather filenames into array
  filenames=( `ls -1t | grep "${file_ext}" | tr '\n' ' '` );
  filenames_count_total=${#filenames[@]};
  filenames_count_success=0;
  filenames_count_failure=0;
  message_output ${MSG_CONSOLE} " Scanned ${filenames_count_total} ${file_ext} files in ${PWD#${main_path_prefix}}/"

  # Iterate over filenames array
  for file_name in ${filenames[@]}
    do
      # Is this truly a file?
      if [[ -e "${file_name}" ]]; then
        # Yes, it's a file. Snapshot the old name, and call the task.
        #message_output ${MSG_NOTICE} " FOUND A FILE: ${file_name}"
        orig_file_name=${file_name}; # Keep the old filename around.
        task ${file_name};  # Execute the task function of the loaded task.
      fi
    done
  message_output ${MSG_CONSOLE} " Completed operations on ${filenames_count_success} of ${filenames_count_total} ${file_ext} files in ${PWD#${main_path_prefix}}/ at ${SECONDS} seconds.";
}

iterate_directories()
{
  if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then
  message_output ${MSG_TRACE} "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME[@]} "with ${#@} params:" ${@}; fi
  if [[ ${ft_multidir} ]]; then
    message_output ${MSG_VERBOSE} "  Recursive Searching Multiple Source Directories.";
    gather_directories;
    # DIRSTACK starts out with a useless entry to ".", we'll just stop at 1.
    # Otherwise this would read: for dir_name in ${DIRSTACK[@]}
    while [[ "${#DIRSTACK[@]}" -gt "1" ]]
      do
        message_output ${MSG_INFO} "Directory Stack Contents (${#DIRSTACK[@]}): ${DIRSTACK[@]}.";
        task_multidir_pre; # Fired before we leave the directory
        popd; # Traverse to new directory from the contents of $DIRSTACK
        dir_name=${PWD#${source_path}}; # Stripping the source path allows constant ar_file_path IDs
        message_output ${MSG_VERBOSE} "  Traversed to ${dir_name}";
        task_multidir_info; # Fired to gather information on the directory's contents
        iterate_files; # Fired to perform task() operations on files in directory
        task_multidir_post; # Fired after completing a directory
      done
    task_complete; # Fired to indicate task completion
    return 0; # Success
  else
    message_output ${MSG_VERBOSE} "  Searching Single Source Directory.";
    iterate_files; # Fired to perform task() operations on files in directory
    task_complete; # Fired to indicate task completion
    return 0; # Success
  fi
}

gather_directories()
{
  if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then
  message_output ${MSG_TRACE} "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME[@]} "with ${#@} params:" ${@}; fi
  IFS=$'\n';   # Enable for loops over items with spaces in their name
  # Magic Command to run to gather directory list
  #local dirsource=`ls -1Ft | grep "/"`
  local dirsource=`walk_dirtree $PWD`;
  IFS=${OLDIFS};  # Restore IFS

  # Gather filenames into array
  local directory_names=( ${dirsource} );
  message_output ${MSG_VERBOSE} "  Found ${#directory_names[@]} source directories.";

  # Clear the directory stack once
  dirs -c;

  # Iterate over directories array
  for directory_name in ${directory_names[@]}
    do
      # Is this entry a directory?
      if [[ -d "${directory_name}" ]]; then
        message_output ${MSG_INFO} " FOUND A DIRECTORY:" `readlink -f ${directory_name}`;
        # Yep, it's a directory.
        # Add it to the Iterate list to discover the files inside.
        # NOTE: pushd -n will add to $DIRSTACK without changing $PWD.
        # NOTE: `readlink -f $dir` will expand the full path.
        pushd -n `readlink -f ${directory_name}`;
      fi
    done
  message_output ${MSG_CONSOLE} " Completed discovery in ${#directory_names[@]} source directories:\n    ${directory_names[@]#${main_path_prefix}} ";
}

walk_dirtree() # RECURSIVE ECHO -- BACKTICK MY CALL!
{ # Call: `walk_dirtree <base_directory>`
  if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then
  IFS=${OLDIFS}; message_output ${MSG_TRACE} "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME[@]} "with ${#@} params:" ${@}; fi
  ls -1Ft "${1}" | grep "/" | while IFS=$'\n' read directory; do  # magic directory filter
    if [ -d "${1}/${directory}" ]; then # if it's a directory
      # NOTE: pushd -n will add to $DIRSTACK without changing $PWD.
      # NOTE: `readlink -f $dir` will expand the full path.
      echo `readlink -f ${1}/${directory}`"/"; # Add it to the queue
      walk_dirtree "${1}/${directory%"/"}"; # Recurse into directory
    fi
  done
}

# Start Sub Routines

# End Sub Routines

# -----------
# End Functions
# -----------

# Load File Operation Functions
source ${script_path}/ft_common/ft_file_ops.sh

# Load File Compression Functions
source ${script_path}/ft_common/ft_file_compression.sh

# Load File Matching Functions
source ${script_path}/ft_common/ft_file_matching.sh

# -----------
# Main Program
# -----------

# Output Loader information
if [[ -e "${script_path}/ft_config/ft_config_verbose.on" ]]; then
  echo "  FileTasker File Core Module Loaded at ${SECONDS} seconds."; fi
# -----------
# End Main Program
# -----------
