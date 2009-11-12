#!/bin/bash
# -----------
# FileTasker Task for LDM
# -----------
# CMDLine Inputs: NIL
# -----------
# First run: symlink files from old location and old name to new location and new name
# Upon new storage, unlink old names, move & rename files to new location.
#
# -----------
# Filename Inputs:
# GRIB
#  034500.grib
# -----------
# Filename Outputs:
# GRIB
#  ldm.ncfw6.120m_fcst.20090707.034500.grib
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
task_name="ldm"
# LDM's log filename is overridden in task_init_hook below!
logfile_filename="${task_name}"

# Look for files of type...
file_ext=".grib"

# filename segments are seperated by...
#parse_seperator="."
# Defaults to "."

# For tasks with files in multiple directories.
ft_multidir=1

# Turn on output compression for this task
ft_output_compression="gzip"

# Gzip prompts by default if we don't force compression.
compress_flags="-9f"

# -----------
# Paths
# -----------

# Source files are here
source_base_path="${source_path_prefix}weather/ldm/"
source_path="${source_base_path}"
# Target files are here
target_base_path="${target_path_prefix}data/ldm/"
target_path="${target_base_path}"


# -----------
# End Variables
# -----------

# -----------
# Main Task
# -----------

# TODO: note - remote server runs bash3.1, string concat with var+=append works
task_pre()
{
  if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then
  message_output ${MSG_TRACE} "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME[@]} "with ${#@} params:" ${@}; fi
  match_take_snapshot ${file_name} # Take a snapshot of the file
  # Set the right dated source path
  if [[ "$ft_multidir" -eq "1" ]]; then source_path="${source_base_path}${dir_name}/"; fi
  # Parse the dated pathname into $ar_path_name
  parse_pathname ${dir_name}
  # Parse the filename into $ar_file_name
  parse_filename ${file_name}
  # Get the date from the directory the file was stored in.
  parse_to_epoch_from_yyyymmdd_dir ${ar_path_name[1]}
  return 0; # Success
}

task()
{
  if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then
  message_output ${MSG_TRACE} "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME[@]} "with ${#@} params:" ${@}; fi
  
  make_line_header "LDM Working on ${1}"
  
  local my_file_name=${file_name}
  task_pre ${my_file_name}
  local my_file_date=${dir_name}

  # TODO: filter in the source, format, and date from the directory. - DONE
  ar_file_name=( "ldm" "ncfw6" "${ar_path_name[0]}" "${ar_path_name[1]}" "${ar_file_name[@]}" )
  
  # build the filename from ar_file_name
  build_filename

  task_post
  # End of Task
  return 0; # Success
}

task_post()
{
  if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then
  message_output ${MSG_TRACE} "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME[@]} "with ${#@} params:" ${@}; fi
  if match_check_snapshot ${file_name}; then :; else return ${E_MISMATCH}; fi # Bail out early

  # Dated Directory needs to be generated from the timestamp.
  generate_yyyy_mm_dd_date_dir_from_epoch ${file_epoch}
  # Set the right dated target path (date_dir has trailing /)
  target_path="${target_path}${date_dir}${ar_path_name[0]}/"
  # Perform the file operation (takes care of all paths for us)
  perform_fileop ${selected_subtask} ${orig_file_name} ${new_file_name}
  # Set the original source & target path
  source_path="${source_base_path}"
  target_path="${target_base_path}"
  return 0; # Success
}

task_multidir_info() # Called automatically after directory pop, before iterate_files()
{
  # Add the Forecast Time to the log filename.
  logfile_filename="${task_name}_${ar_path_name[0]}"
}

task_complete() # Called automatically at the end of iterate_directories()
{
  # Return to the original log filename.
  logfile_filename="${task_name}"
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
          # ldm_source ends up to be the Forecast Time.
          # EX: "120min_fcst" or "120min_fetop"
          ldm_source=${subtask_args[0]}
          # Add the Forecast Time to the source base path & regen the path.
          source_base_path="${source_base_path}${ldm_source}/"
          source_path="${source_base_path}"
          # Add the Forecast Time to the log filename.
          logfile_filename="${task_name}_${ldm_source}"
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
    echo "   FileTasker LDM Operations Module ${ftask_version} Loaded at ${SECONDS} seconds."
fi

# -----------
# End Main Program
# -----------
