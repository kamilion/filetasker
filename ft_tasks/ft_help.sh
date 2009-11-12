# -----------
# FileTasker Task for FT Help
# -----------
# CMDLine Inputs: NIL
# -----------

# -----------
# End Program Information
# -----------

# -----------
# Variables
# -----------

# -----------
# Arrays
# -----------
task_subtasks=( help )

# -----------
# Strings
# -----------
task_name="ft_help"

# Look for files of type...
file_ext=".sh"

# -----------
# Paths
# -----------


# Source files are here
source_path="${script_path}/ft_tasks/"
# Target files are here
target_base_path="${script_path}/ft_tasks/"

# -----------
# End Variables
# -----------

task_init()
{
        echo "    FT_Help Module - Listing known tasks..."
        return 0;
}

task_help()
{
        echo "    FT_Help Module - Found task ${1}"
        #if [[ "${1}" == "ft_help.sh" ]]; then return 127; else $PWD/${1}; return 0; fi
        $PWD/${1}; # Execute the module for help.
        return 0;
}

# -----------
# Main Program
# -----------

task()
{
    task_help $1
    local return_value=${?}
    if [[ $return_value != 0 ]]; then echo "     Failure. Reason ID: ${return_value}"; fi
    # End of Task
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
if [[ "$parent_script" == "$my_name" ]]
then
    echo "   Supported Subtasks in $my_name: ${task_subtasks[@]}"
else
    echo "   FileTasker Help Module Loaded at $SECONDS seconds."
fi
# -----------
# End Main Program
# -----------
