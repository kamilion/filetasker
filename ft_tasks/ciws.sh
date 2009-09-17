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
# NetCDF
#  edu.mit.ll.wx.ciws.QuantizedEchoTop.Netcdf4.1km.20090402T193730Z.nc
#  edu.mit.ll.wx.ciws.QuantizedEchoTopsForecast.Netcdf4.1km.20090402T193500Z.nc
#  edu.mit.ll.wx.ciws.QuantizedVIL.Netcdf4.1km.20090402T193730Z.nc
#  edu.mit.ll.wx.ciws.QuantizedVILForecast.Netcdf4.1km.20090402T193500Z.nc
# -----------
# Filename Outputs:
# NetCDF
#  ciws_edu.mit.ll.wx.ciws.QuantizedEchoTop.Netcdf4.1km.20090402T193730Z.nc
#  ciws_edu.mit.ll.wx.ciws.QuantizedEchoTopsForecast.Netcdf4.1km.20090402T193500Z.nc
#  ciws_edu.mit.ll.wx.ciws.QuantizedVIL.Netcdf4.1km.20090402T193730Z.nc
#  ciws_edu.mit.ll.wx.ciws.QuantizedVILForecast.Netcdf4.1km.20090402T193500Z.nc
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
task_name="ciws"
debug_filename="${debug_file_date}_${task_name}.log"

# Look for files of type...
file_ext=".nc"

# filename segments are seperated by...
#parse_seperator="."
# Defaults to "."

file_name_prefix="ciws."

# -----------
# Paths
# -----------

# Source files are here
source_base_path="${source_path_prefix}weather/ciws/netcdf/"
source_path="${source_base_path}"
# Target files are here
target_base_path="${target_path_prefix}data/ciws/"
target_path="${target_base_path}"

# -----------
# End Variables
# -----------

# Parses ciws times from 20090402T193730Z to Epoch
parse_to_epoch_from_date_ciws()
{
  if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then
  debug_out "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME[@]} "with ${#@} params:" ${@}; fi
  local file_datestamp=${1}
  file_epoch=`date +%s -d "${file_datestamp:0:4}-${file_datestamp:4:2}-${file_datestamp:6:2} ${file_datestamp:9:2}:${file_datestamp:11:2}:${file_datestamp:13:2} UTC"`
  file_timestamp=`date -u -d @${file_epoch}`
  debug_out " Parsed Filedate: ${file_datestamp} - Date: ${file_datestamp:0:4}-${file_datestamp:4:2}-${file_datestamp:6:2} Time: ${file_datestamp:9:2}:${file_datestamp:11:2}:${file_datestamp:13:2} Zulu - Epoch: @${file_epoch} or ${file_timestamp}"
}

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
  # Remove the first four filename indexes (edu, mit, ll, and wx)
  ar_file_name=("${ar_file_name[@]:4}")
  # Build the filename from ar_file_name
  build_filename 
  transform_operations_post ${new_file_name}
}

# -----------
# Main Task
# -----------
task_pre()
{
  if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then
  debug_out "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME[@]} "with ${#@} params:" ${@}; fi
  match_take_snapshot ${file_name} # Take a snapshot of the file
  # Parse the filename into an array
  parse_filename ${file_name}
  # Get the date
  parse_to_epoch_from_date_ciws ${ar_file_name[8]}
  return 0; # Success
}

task()
{
  if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then
  debug_out "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME[@]} "with ${#@} params:" ${@}; fi

  make_line_header "CIWS Working on ${1}"
  
  local my_file_name=${file_name}
  task_pre ${my_file_name}

  transform_operations ${my_file_name}

  task_post
  # End of Task
  return 0; # Success
}

task_post()
{
  if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then
  debug_out "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME[@]} "with ${#@} params:" ${@}; fi
  if [[ `match_check_snapshot ${file_name}` ]]; then debug_out " TASK SAYS FILES MISMATCH"; return ${E_MISMATCH}; fi # Bail out early

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
    echo "   FileTasker CIWS Operations Module ${ftask_version} Loaded at ${SECONDS} seconds."
fi

# -----------
# End Main Program
# -----------
