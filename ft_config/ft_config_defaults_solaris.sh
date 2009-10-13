# -----------
# FileTasker Global Solaris/SunOS Configuration Script
# -----------
# CMDLine Inputs: NIL (Not Executable)
# -----------
# Common Operations Functions
# Sourced by filetasker.sh
# -----------
# End Program Information
# -----------

# -----------
# Variable Defaults
# -----------
date() { $(dirname `which readlink`)/date }

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
# End Functions
# -----------

# -----------
# Main Program
# -----------

# Output Loader information
if [[ -e "${script_path}/ft_config/ft_config_quiet.off" ]]; then
  echo "  FileTasker Solaris/SunOS Configuration Module ${ftask_version} Loaded at ${SECONDS} seconds."; fi
# -----------
# End Main Program
# -----------
