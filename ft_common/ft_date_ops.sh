# -----------
# FileTasker Date Operations Script
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

# -----------
# Date Functions
# -----------

# Notes: We try to keep dates in the most sanely digestable format:
# Unix time_t Epoch time. (Seconds since Jan 1 1970 00:00:00 GMT)
# 32Bit time_t machines may have trouble with dates after August 2037.
# 64bit time_t machines support dates well into the billions of years.

# Parsers

# Parses non-compliant times from 20090402T193730Z to an Epoch
# Inputs: $1 - String "YYYYMMDD?HHMMSS*"
# Outputs: $file_epoch - Contains date in epoch format
parse_to_epoch_from_date_generic()
{
  if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then
  message_output ${MSG_TRACE} "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME[@]} "with ${#@} params:" ${@}; fi
  local file_datestamp=$1
  local file_year=${file_datestamp:0:4}
  local file_month=${file_datestamp:4:2}
  local file_day=${file_datestamp:6:2}
  local file_hours=${file_datestamp:9:2}
  local file_mins=${file_datestamp:11:2}
  local file_secs=${file_datestamp:13:2}
  file_epoch=`date +%s -d "${file_year}-${file_month}-${file_day} ${file_hours}:${file_mins}:${file_secs} UTC"`
  file_timestamp=`date -u -d @${file_epoch}`
  message_output ${MSG_INFO} " Parsed Filedate: ${file_datestamp} - Date: ${file_year}-${file_month}-${file_day} Time: ${file_hours}:${file_mins}:${file_secs} Zulu - Epoch: @${file_epoch} or ${file_timestamp}"
}

# Parses a date structured directory to an Epoch.
# Inputs: $1 - String "YYYY?MM?DD*"
# Outputs: $file_epoch - Contains date in epoch format
parse_to_epoch_from_yyyy_mm_dd_dir()
{
  if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then
  message_output ${MSG_TRACE} "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME[@]} "with ${#@} params:" ${@}; fi
  local my_year=${1:0:4}
  local my_month=${1:5:6}
  local my_day=${1:8:9}
  local my_date="${my_year}${my_month}${my_day}"
  echo ${my_date}
  file_epoch=`date +%s -d $my_date`
  file_timestamp=`date -u -d @${file_epoch}`
  message_output ${MSG_INFO} " Parsed Dirdate: ${my_date} - Date: ${my_year}-${my_month}-${my_day} - Epoch: @${file_epoch} or ${file_timestamp}"
}

# Parses a date structured directory to an Epoch.
# Inputs: $1 - String "YYYYMMDD*"
# Outputs: $file_epoch - Contains date in epoch format
parse_to_epoch_from_yyyymmdd_dir()
{
  if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then
  message_output ${MSG_TRACE} "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME[@]} "with ${#@} params:" ${@}; fi
  local my_date=${1:0:8}
  file_epoch=`date +%s -d $my_date`
  file_timestamp=`date -u -d @${file_epoch}`
  message_output ${MSG_INFO} " Parsed Dirdate: ${my_date} - Epoch: @${file_epoch} or ${file_timestamp}"
}

# Generators

# Generates a date structured directory from an Epoch.
# Inputs: $1 - EpochTime
# Outputs: $date_dir - Contains date in YYYY/MM/DD/ format
generate_yyyy_mm_dd_date_dir_from_epoch()
{
  if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then
  message_output ${MSG_TRACE} "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME[@]} "with ${#@} params:" ${@}; fi
  local my_epoch=${1}
  local file_year=`date +%Y -u -d @${my_epoch}`
  local file_month=`date +%0m -u -d @${my_epoch}`
  local file_day=`date +%0d -u -d @${my_epoch}`
  date_dir="${file_year}/${file_month}/${file_day}/"
  message_output ${MSG_INFO} " Generated Date Directory from: ${my_epoch} to: ${date_dir}"
}

# Generates a date structured directory from an Epoch.
# Inputs: $1 - EpochTime
# Outputs: $date_dir - Contains date in YYYYMMDD/ format
generate_yyyymmdd_date_dir_from_epoch()
{
  if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then
  message_output ${MSG_TRACE} "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME[@]} "with ${#@} params:" ${@}; fi
  local my_epoch=${1}
  local file_year=`date +%Y -u -d @${my_epoch}`
  local file_month=`date +%0m -u -d @${my_epoch}`
  local file_day=`date +%0d -u -d @${my_epoch}`
  date_dir="${file_year}${file_month}${file_day}/"
  message_output ${MSG_INFO} " Generated Date Directory from: ${my_epoch} to: ${date_dir}"
}

# Subroutines

# Calling mkdir with the -p option will populate nonexistant parent dirs.
check_and_create_target_dirs()
{
  generate_dir ${target_path}
}

# -----------
# End Functions
# -----------

# -----------
# Main Program
# -----------

# Output Loader information
echo "  FileTasker Date Operations Module ${ftask_version} Loaded at ${SECONDS} seconds."
# -----------
# End Main Program
# -----------
