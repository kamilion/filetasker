# -----------
# FileTasker LinkList Operations Script
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
# File Functions
# -----------

# Hooks for pre and post operations
# Inputs: ${1} source
tar_file_pre () { :; }
tar_file_post () { :; }

# Hooks for pre and post operations
# Inputs: ${1} source
untar_file_pre () { :; }
untar_file_post () { :; }

# Hooks for pre and post operations
# Inputs: ${1} source
compress_gzip_file_pre () { :; }
compress_gzip_file_post () { :; }

# Hooks for pre and post operations
# Inputs: ${1} source
decompress_gzip_file_pre () { :; }
decompress_gzip_file_post () { :; }

# Hooks for pre and post operations
# Inputs: ${1} source - ${2} destination
move_file_pre () { update_linklist_paths; }
move_file_post ()  { update_linklist ${2}; }

# Hooks for pre and post operations
# Inputs: ${1} source - ${2} destination
copy_file_pre () { update_linklist_paths; }
copy_file_post () { update_linklist ${2}; }

# Hooks for pre and post operations
# Inputs: ${1} source - ${2} destination
link_file_pre () { update_linklist_paths; }
link_file_post () { update_linklist ${2}; }

# Hooks for pre and post operations
# Inputs: ${1} source - ${2} destination
debug_file_pre () { update_linklist_paths; }
debug_file_post () { debug_out "  Would have linked `basename ${2}` to ${linkdir_path}"; }

# Start Sub Routines

add_to_linklist() { echo ${1} >> ${linkfile_path}${task_name}.links; }
add_to_linkdir() { cp -sf ${1} ${linkdir_path}; }
update_linklist()
{
  if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then
  debug_out "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME[@]} "with ${#@} params:" ${@}; fi
  if [[ -e "${script_path}/ft_config/ft_config_gen_linklist.on" ]]; then
  debug_out "  LinkList: Now linking `basename ${1}` to ${linkdir_path}" 
  add_to_linkdir ${1}
  add_to_linklist `basename ${1}`
  fi
}
# Updates the variables during a running task
update_linklist_paths()
{
  if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then
  debug_out "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME[@]} "with ${#@} params:" ${@}; fi
  linklist_path="${target_base_path}dblinks/";
  linkdir_path="${linklist_path}";
  linkfile_path="${linkdir_path}linkfiles/";
  generate_dir ${linkfile_path}
}


# End Sub Routines

# -----------
# End Functions
# -----------

# -----------
# Main Program
# -----------

# Output Loader information
echo "  FileTasker LinkList Operations Module ${ftask_version} Loaded at ${SECONDS} seconds."
# -----------
# End Main Program
# -----------
