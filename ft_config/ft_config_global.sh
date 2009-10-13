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
if [[ `uname` == 'SunOS' ]]; then
  source ${script_path}/ft_config/ft_config_defaults_solaris.sh
elif [[ `uname` == 'Linux' ]]; then
  source ${script_path}/ft_config/ft_config_defaults_linux.sh
fi

# -----------
# Arrays
# -----------

# -----------
# Strings
# -----------

# -----------
# Paths
# -----------

# Load Global Path Configuration
source ${script_path}/ft_config/ft_config_paths.sh

# Path to write logs & tracefiles to
logfile_path="${script_path}/ft_logs/"
# This is the default log file name if a task does not redefine it.
logfile_filename="ft_core"
# Define the logfilename backup 'generic' date format: YYYYMMDD_HHMMSS
logfile_date=`date +%Y%0m%0d_%0H%0M%0S`
# Logs over 100KB are automatically gzipped.
logfile_maxsize=100000

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
if [[ -e "${script_path}/ft_config/ft_config_quiet.off" ]]; then
  echo "  FileTasker Global Configuration Module ${ftask_version} Loaded at ${SECONDS} seconds."; fi
# -----------
# End Main Program
# -----------
