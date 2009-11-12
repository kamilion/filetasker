# -----------
# FileTasker File Compression Script
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
# Compression Functions
# -----------

# Hooks for pre and post operations
tar_file_pre () { :; }
tar_file_post () { :; }
tar_file ()
{
  tar_file_pre ${1}
  message_output ${MSG_VERBOSE} "  Tarring" ${1#${main_path_prefix}}
  tar ${tar_flags:='-cvf'} ${1}
  local returnval=$?
  tar_file_post ${1}
  return $returnval;
}

# Hooks for pre and post operations
untar_file_pre () { :; }
untar_file_post () { :; }
untar_file ()
{
  untar_file_pre ${1}
  message_output ${MSG_VERBOSE} "  Untarring" ${1#${main_path_prefix}}
  tar ${untar_flags:='-xvf'} ${1}
  local returnval=$?
  untar_file_post ${1}
  return $returnval;
}

# Hooks for pre and post operations
compress_gzip_file_pre () { :; }
compress_gzip_file_post () { :; }
compress_gzip_file ()
{
  compress_gzip_file_pre ${1}
  message_output ${MSG_VERBOSE} "  Compressing" ${1#${main_path_prefix}}
  gzip ${compress_flags:='-9f'} ${1}
  local returnval=$?
  compress_gzip_file_post ${1}
  return $returnval;
}

# Hooks for pre and post operations
decompress_gzip_file_pre () { :; }
decompress_gzip_file_post () { :; }
decompress_gzip_file ()
{
  decompress_gzip_file_pre ${1}
  message_output ${MSG_VERBOSE} "  Decompressing" ${1#${main_path_prefix}}
  gzip ${decompress_flags:='-vd'} ${1}
  local returnval=$?
  decompress_gzip_file_post ${1}
  return $returnval;
}

# Start Sub Routines

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

# End Sub Routines

# -----------
# End Functions
# -----------

# -----------
# Main Program
# -----------

# Output Loader information
if [[ -e "${script_path}/ft_config/ft_config_loud.on" ]]; then
  echo "  FileTasker File Compression Module ${ftask_version} Loaded at ${SECONDS} seconds."; fi
# -----------
# End Main Program
# -----------
