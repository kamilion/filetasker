#!/bin/bash
# -----------
# FileTasker Task for NFDC
# -----------
# CMDLine Inputs: NIL
# -----------
# First run: symlink files from old location and old name to new location and new name
# Upon new storage, unlink old names, move & rename files to new location.
#
# -----------
# Filename Inputs:
# GZIP
#  nfdc.[source].CCU_[CCU date_format].gz
# -----------
# Filename Outputs:
# GZIP
#  nfdc.[source].CCU_[CCU date_format].gz
#  nfdc.apt.CCU_20090702.gz
# -----------
# 
# CCU (Chart Change Update) date_format = yyyymmdd - 56 day cycle
# NFDC_Sources=( apt, arb, awy, fix, ils, nav, stardp, sua )
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
task_name="nfdc"

debug_filename="${debug_file_date}_${task_name}.log"

# Look for files of type...
file_ext=".gz"

# filename segments are seperated by...
#parse_seperator="."
# Defaults to "."

# For tasks with files in multiple directories.
#ft_multidir=1

# Turn on output compression for this task
ft_output_compression="gzip"

# -----------
# Paths
# -----------

# Source files are here
source_base_path="${source_path_prefix}weather/nfdc/"
source_path="${source_base_path}"
# Target files are here
target_base_path="${target_path_prefix}data/nfdc/"
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
  if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then
  debug_out "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME[@]} "with ${#@} params:" ${@}; fi
  local my_file_name=${1}
  transform_operations_pre ${my_file_name}
  
  # Add more array translations here.
  #local my_file_source=${ar_path_name[5]}
  local my_file_date=${dir_name}

  # TODO: filter in the source, format, and date from the directory. - DONE
  # ar_file_name=( "nfdc" "apt" "CCU_20090702" "${my_file_date}" "${ar_file_name[@]}" )
  
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
  if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then
  debug_out "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME[@]} "with ${#@} params:" ${@}; fi
  match_take_snapshot ${file_name} # Take a snapshot of the file
  # Parse the filename into $ar_file_name
  parse_filename ${file_name}
  # Get the date from the directory the file was stored in.
  parse_to_epoch_from_yyyymmdd_dir ${ar_file_name[2]:4}
  # Set the right dated source path
  if [[ "$ft_multidir" -eq "1" ]]; then source_path="${source_base_path}${dir_name}/"; fi
  # Parse the full dated pathname afterwards
  parse_pathname ${source_path}
  return 0; # Success
}

task()
{
  if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then
  debug_out "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME[@]} "with ${#@} params:" ${@}; fi
  
  make_line_header "NFDC Working on ${1}"
  
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
  if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then
  debug_out "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME[@]} "with ${#@} params:" ${@}; fi
  if match_check_snapshot ${file_name}; then :; else return ${E_MISMATCH}; fi # Bail out early

  # Dated Directory needs to be generated from the timestamp.
  generate_yyyymmdd_date_dir_from_epoch ${file_epoch}
  # Set the right dated target path (date_dir has trailing /)
  target_path="${target_path}${date_dir}"
  # Perform the file operation (takes care of all paths for us)
  perform_fileop ${selected_subtask} ${orig_file_name} ${new_file_name}
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
      if [[ "${subtask_args[0]}" != "" ]]; then
          nfdc_source=${subtask_args[0]}
          source_base_path="${source_base_path}${nfdc_source}/"
          source_path="${source_base_path}"
      fi
      # Too many params?
      if [[ "${subtask_args[1]}" != "" ]]; then
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
    echo "   FileTasker NFDC Operations Module ${ftask_version} Loaded at ${SECONDS} seconds."
fi

# -----------
# End Main Program
# -----------
