#!/bin/bash
# -----------
# FileTasker Task for TRACON
# -----------
# CMDLine Inputs: NIL
# -----------
# First run: symlink files from old location and old name to new location and new name
# Upon new storage, unlink old names, move & rename files to new location.
#
# -----------
# Filename Inputs:
# GZIP
#  [adaptation_set]_ad??_capture_yyyymmdd.gz
#  D10_adar_capture_20090405.gz
# -----------
# Filename Outputs:
# GZIP
#  tracon.[adaptation_set].ad??_capture.yyyymmdd.gz
#  tracon.D10_DFW.adar_capture.20090331.gz
# -----------
# 
# adaptation_set=( ZAB_P50, ZAU_C90, ZAU_MKE, ZAU_SBN, ZBW_A90, ZBW_N90, ZDC_PCT, ZDV_D01, D10_DFW, ZHU_I90, ZID_CVG, ZJX_MCO, ZKC_T75, ZLA_L30, ZLA_SCT, ZLC_S56, ZMA_MIA, ZME_MEN, ZMP_M98, ZNY_N90, ZNY_PHL, ZOA_NCT, ZOB_D21, ZSE_P80, ZSE_S46, ZTL_A80, ZTL_CTL )
# 
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
task_name="tracon"
# TRACON's debug filename is overridden in task_init_hook below!
debug_filename="${debug_file_date}_${task_name}.log"

# Look for files of type...
file_ext=".gz"

# filename segments are seperated by...
parse_seperator="_"
# Defaults to "."

# For tasks with files in multiple directories.
#ft_multidir=1

# -----------
# Paths
# -----------

# Source files are here
source_base_path="${source_path_prefix}weather/tracon/"
source_path="${source_base_path}"
# Target files are here
target_base_path="${target_path_prefix}data/tracon/"
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
  
  # Add more array translations here.
  #local my_file_source=${ar_path_name[5]}
  local my_file_date=${ar_file_name[3]}

  # TODO: filter in the source, format, and date from the directory. - DONE
  #ar_file_name[0]="D10_DFW"
  ar_file_name=( "tracon" "D10_DFW" "adar_capture" "${my_file_date}" )

  
  # build the filename from ar_file_name
  build_filename 
  transform_operations_post ${new_file_name}
}

# -----------
# Main Task
# -----------

# TODO: note - remote server runs bash3.1, string concat with var+=append works
task_pre()
{
  debug_out "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME} "with ${#@} params:" ${@}
  file_size=`stat -c %s ${file_name}`   # Get Filesize
  file_mtime=`stat -c %Y ${file_name}`   # Get Last Written To in Epoch
  # Parse the filename into $ar_file_name
  parse_filename ${file_name}
  # Get the date from the directory the file was stored in.
  parse_to_epoch_from_yyyymmdd_dir ${ar_file_name[3]}
  # Set the right dated source path
  # source_path="${source_path}${dir_name}/"
  # Parse the full dated pathname afterwards
  parse_pathname ${source_path}
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
  # We should compress data if it is not already.
  check_and_compress_gzip_file ${new_file_name}
  # Set the original source & target path
  source_path="${source_base_path}"
  target_path="${target_base_path}"
  return 0; # Success
}

: <<COMMENTBLOCK
# Hook into the task initializer to pick up our subtask params
task_init_hook()
{
  if [[ "${subtask_args[@]}" == "" ]]
    then
      echo "   Error: Subtask requires additional arguements."
      echo "   Supported Subtasks in ${task_name}: ${task_subtasks[@]}"
      quit_filetasker
      exit ${E_BADARGS};
    else
      # TODO: Add arg check for sourcetype
      if [ "${subtask_args[0]}" != "" ]; then
          tracon_source=${subtask_args[0]}
          source_base_path="${source_base_path}${tracon_source}/"
          source_path="${source_base_path}"
      fi
      # Too many params?
      if [ "${subtask_args[1]}" != "" ]; then
          echo "   Error: Subtask given too many arguements."
          quit_filetasker
          exit ${E_BADARGS};
      fi
  fi
  #echo "SUBTASK GOT ARGS: ${subtask_args[@]}"
}
COMMENTBLOCK

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
    echo "   Supported Subtasks in $my_name: ${task_subtasks[@]}"
else
    echo "   FileTasker TRACON Operations Module ${ftask_version} Loaded at ${SECONDS} seconds."
fi

# -----------
# End Main Program
# -----------
