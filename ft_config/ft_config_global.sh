# -----------
# FileTasker Global Configuration Script
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

# -----------
# Arrays
# -----------

# -----------
# Strings
# -----------

# -----------
# Paths
# -----------

# Load Path Configuration
source ${script_path}/ft_config/ft_config_paths.sh

# -----------
# End Variables
# -----------


# -----------
# Functions
# -----------

# -----------
# End Functions
# -----------

# Load Local Configuration
source ${script_path}/ft_config/ft_config_local.sh

# -----------
# Main Program
# -----------

# Output Loader information
echo "  FileTasker Global Configuration Module ${ftask_version} Loaded at ${SECONDS} seconds."
# -----------
# End Main Program
# -----------
