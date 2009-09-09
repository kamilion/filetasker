#!/bin/bash
# -----------
# FileTasker Task for CIWS Debug
# -----------
# CMDLine Inputs: NIL
# -----------
# First run: symlink files from old location and old name to new location and new name
# Upon new storage, unlink old names, move & rename files to new location.
#
# -----------
# Filename Inputs:
# HD5
#  2008_08_13_02_20_GMT.Forecast.h5.gz
# -----------
# Filename Outputs:
# HD5
#  ciws_2008_08_13_02_20_UTC.Forecast.h5.gz
# -----------
# End Program Information
# -----------

# -----------
# Variables
# -----------

# -----------
# Arrays
# -----------
task_subtasks=( debug link copy move )

# -----------
# Strings
# -----------
task_name="ciwslegacy"
debug_filename="${debug_file_date}_${task_name}.log"

# Look for files of type...
file_ext=".h5.gz"

# filename segments are seperated by...
parse_seperator="_"
# Defaults to "."

file_name_prefix="ciws."

# -----------
# Paths
# -----------

# Source files are here
source_base_path="${source_path_prefix}weather/ciws/hd5/"
source_path="${source_base_path}"
# Target files are here
target_base_path="${target_path_prefix}data/ciws/legacy/"
target_path="${target_base_path}"

# -----------
# End Variables
# -----------


#Main Transformation Worker Function
transform_operations_pre () { :; }
transform_operations_post () { :; }
#Input: $1: Filename
transform_operations()
{
  debug_out "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME} "with ${#@} params:" ${@}
  local my_file_name=${1}
  transform_operations_pre ${my_file_name}
  # Add the prefix to index 0
  ar_file_name[0]="${file_name_prefix}${ar_file_name[0]}"
  # Change GMT to UTC
  ar_file_name[5]="${ar_file_name[5]/GMT/UTC}"
  # build the filename from ar_file_name
  build_filename 
  transform_operations_post ${new_file_name}
}

# -----------
# Main Task
# -----------
task_pre()
{
  debug_out "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME} "with ${#@} params:" ${@}
  file_size=`stat -c %s ${file_name}`   # Get Filesize
  file_mtime=`stat -c %Y ${file_name}`   # Get Last Written To in Epoch
  # Parse the filename into an array
  parse_filename ${file_name}
  # Get the date
  local generic_file_date="${ar_file_name[0]}${ar_file_name[1]}${ar_file_name[2]}T${ar_file_name[3]}${ar_file_name[4]}00UTC"
  parse_to_epoch_from_date_generic ${generic_file_date}
  return 0; # Success
}

task()
{
  debug_out "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME} "with ${#@} params:" ${@}
  local my_file_name=${file_name}
  task_pre ${my_file_name}

  # Filename transformation
  transform_operations ${my_file_name}

  task_post
  # End of Task
  return 0; # Success
}

task_post()
{
  debug_out "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME} "with ${#@} params:" ${@}
  debug_out " Sleeping for 2 seconds for mtime check..."; sleep 2; # Snooze for a couple seconds, waiting for mtimes to change?
  file_size_new=`stat -c %s ${file_name}`   # Get Filesize
  file_mtime_new=`stat -c %Y ${file_name}`   # Get Last Written To in Epoch  
  if [ files_match ];
   then
    debug_out " Files MATCH  -- PROCESSING THIS FILE"
   else
    debug_out " Files MISMATCH -- IGNORING THIS FILE"
    return ${E_MISMATCH}; # Bail out early
  fi
  # Dated Directory needs to be generated from the timestamp.
  generate_yyyy_mm_dd_date_dir_from_epoch ${file_epoch}
  # Set the right dated target path (date_dir has trailing /)
  target_path="${target_path}${date_dir}"
  # Check/Create our destination directory (No args)
  check_and_create_target_dirs
  # Perform the file operation (takes care of all paths for us)
  perform_fileop ${selected_subtask} ${orig_file_name} ${new_file_name}
  # Set the original source & target path
  source_path="${source_base_path}"
  target_path="${target_base_path}"
  return 0; # Success
}
# -----------
# End Main Task
# -----------

# -----------
# Main Program
# -----------

# Output Loader information
my_name=`basename ${BASH_SOURCE}` # What's this script's name?
parent_script=`basename ${0}` # Who called me?
if [[ "${parent_script}" == "${my_name}" ]]
then
    echo "   Supported Subtasks in ${my_name}: ${task_subtasks[@]}"
else
    echo "   FileTasker CIWS Legacy Operations Module ${ftask_version} Loaded at ${SECONDS} seconds."
fi

# -----------
# End Main Program
# -----------
