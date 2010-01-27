#!/bin/bash
# -----------
# FileTasker Global Task for OTTR
# -----------
# CMDLine Inputs: NIL
# -----------
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
task_subtasks=( chain )

# -----------
# Strings
# -----------
task_name="ottr"

# -----------
# Paths
# -----------

# Source files are here
source_base_path="${source_path_prefix}weather/ottr/"
source_path="${source_base_path}"
# Target files are here
target_base_path="${target_path_prefix}data/ottr/"
target_path="${target_base_path}"


# -----------
# End Variables
# -----------

# -----------
# Main Task
# -----------


# Hook into the task initializer to pick up our subtask params
task_init_hook()
{
  chain_task ottr-csv debug
  chain_task ottr-html debug
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
    echo "   Supported Subtasks in $my_name: ${task_subtasks[@]}"
else
    echo "   FileTasker LDM Global Operations Module Loaded at ${SECONDS} seconds."
fi

# -----------
# End Main Program
# -----------
