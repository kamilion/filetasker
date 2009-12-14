#!/bin/bash
# -----------
# FileTasker Script
ftask_version="V0.7r24";
# Output Initial Greeting
echo "";
echo " FileTasker ${ftask_version}";
# Script's path
script_location=`readlink -f ${BASH_SOURCE}`;
script_path=`dirname ${script_location}`;
# Kill Switch (Stop runaway script without aborting)
if [[ -e "${script_path}/ft_config/ft_config_abort_next.on" ]]
  then
    echo "   Error: Abort Next Task was requested.";
    exit 0;
fi
# -----------
# CMDLine Inputs: $1: "task_name" $2: "subtask_name" $3+: Passed to Task
# -----------
# Perform a list of operations to one or many files according to rules defined in a taskfile.
# 
# Dependancies:
# GNU BASH 3.1+, GNU Coreutils 5.x/6.x, GNU Grep/EGrep 2.5.x+, GNU Gzip, GNU Tar, OpenSSH 3.9+
# Needs: date, stat, head, basename, dirname, readlink, sha1sum
#
# ft_logs dir needs to be writable by the user executing FileTasker.
# 
# Designed in 2009 by Pravin Tahiliani
# Written in 2009 by Graham Cantin
#
# Revision Notes:
# V0.6R214: clobber/Noclobber support
# Each type of operation (move, copy, link, tar, untar, compress, decompress) has a flags variable.
# This can be set in a taskfile as follows
# move_flags="-f" # Clobber existing files
# move_flags="-u" # Don't Clobber existing files (default)
# copy_flags="-f" # Clobber existing files
# copy_flags="-u" # Don't Clobber existing files (default)
# Check ft_file_ops.sh for more information.
# NOTE: look for variables like ${link_flags:='-su'} 
# Braced variables with ":=" sets the default if not previously defined.
#
# -----------
# End Program Information
# -----------

# Source Global Configuration
source ${script_path}/ft_config/ft_config_global.sh;

# -----------
# Variables
# -----------

# -----------
# Error Codes
# -----------

E_BADARGS=65;   # Wrong number of arguments passed to script.

# -----------
# Arrays
# -----------

# -----------
# Strings
# -----------

# -----------
# Paths
# -----------

# Set our root operational directories from ft_config.
source_path_prefix=${main_path_prefix};
target_path_prefix=${main_path_prefix};

# -----------
# End Variables
# -----------

# Source Common Operations
source ${script_path}/ft_common/ft_common_ops.sh;

# -----------
# Main Program
# -----------
#Backup Input Field Separator
OLDIFS=${IFS};

# Snapshot our cmdline args
ft_args=( ${@} );
task_name=${ft_args[0]};
subtask_name=${ft_args[1]};

# Were we passed a task? If not, bail out now.
MIN_NUM_ARGS=1
# Make sure [ doesn't barf with untyped variable vs String - Quote it!
if [[ "${#}" -lt "${MIN_NUM_ARGS}" ]]
  then
    echo "   Error: No taskfile specified.";
    load_task ft_help; # Unspecified Error
  else
    # Shift the args over past the task & subtask.
    shift 2;
    subtask_args=( ${@} );
    # Load Task
    load_task ${task_name};
    # Were we passed a subtask? If not, bail out now.
    if [[ "${subtask_name}" == "" ]]
      then
        echo "   Error: No subtask specified."
        echo "   Supported Subtasks in $1: ${task_subtasks[@]}"
        quit_filetasker;
        exit ${E_BADARGS};
      else
        # Load SubTask
        select_subtask ${subtask_name};
        if [[ "${subtask_args[@]}" != "" ]]; then # Silent if blank.
          echo "   Parameters for ${selected_subtask} subtask: ${subtask_args[@]}";
        fi
    fi    
fi

message_output ${MSG_INFO} "------";
message_output ${MSG_INFO} "LOG SECTION BEGIN";
message_output ${MSG_STATUS} "Starting up:" `basename ${BASH_SOURCE}` "now executing with ${#ft_args} params:" ${ft_args[@]};


# Set up ft environment from ft_common_ops.sh
# This is the main initializer function that sets ft up for a task to be run.
# Currently, changes to source directory. Throws a wobbly if we can't find it.
start_filetasker;

# Iterate over the files.
# After start places us in the right directory, we can gather the contents
# into an array and call "task $filename" on each file.
iterate_directories;

# Okay, all done, time to quit.
# Brings us back to the directory we started in and blows you kisses goodbye.
quit_filetasker;

# Unconditional restore back to the old IFS
IFS=${OLDIFS};
exit 0; # Success
# -----------
# End Main Program
# -----------
