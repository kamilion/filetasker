# -----------
# FileTasker Path Configuration Script
# -----------
# CMDLine Inputs: NIL (Not Executable)
# -----------
# Common Operations Functions
# Sourced by ft_config_global.sh
# -----------
# End Program Information
# -----------

# -----------
# Variable Defaults
# -----------

# -----------
# Paths
# -----------

# Our root operational directory.
# This is the prefix every file-based function will use.
main_path_prefix="/workspace/filetasker/home/"

# -----------
# End Variables
# -----------

# -----------
# Main Program
# -----------

# Output Loader information
if [[ -e "${script_path}/ft_config/ft_config_quiet.off" ]]; then
  echo "  FileTasker Path Configuration Module ${ftask_version} Loaded at ${SECONDS} seconds."; fi
# -----------
# End Main Program
# -----------
