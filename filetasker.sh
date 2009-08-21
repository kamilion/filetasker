#!/bin/bash
# -----------
# FileTasker Script
ftask_version="V0.6r217"
# Output Initial Greeting
echo ""
echo " FileTasker ${ftask_version}"
# Script's path
script_location=`readlink -f ${BASH_SOURCE}`
script_path=`dirname ${script_location}`
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
# R214: clobber/Noclobber support
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
# Major Revision Changelog & TODO:
# V0.1: Remove filename's prefix ("edu.mit.ll.wx")
# V0.2: Perform operation on the file, adding the prefix back in.
# V0.3: Split filename by "." into new array
# V0.4: Alter Array to match new format
# V0.5: Rearchitected to "Task" based format
# R118: Check that files and dirs exist
# R120: Add support for Tar archiving
# R121: Add support for Compression / Decompression
# R122: Change path stuff for user sandboxes (need to use data files from /home/username/*.nc)
# R131: Add support for parsing of dates from Filenames
# R135: Add support for subtasks, combined all tasks
# R136: Add support for 'cron' operations (noclobber)
# R137: Add support for 'force' operations
# R138: Extended help support with ft_help.sh module
# R139: Add support for File size / mtime checking with stat while we process
# R140: Added FuncDebug support
# R141: Add support for log rotation
# R142: fix delay for File modification time checking with stat
# R143: Moved some bits around, abstracted the CIWS date parsing
# R144: Cleanup, improved FuncDebug syntax, more debug code, logger improvements
# R145: Add unix2dos for log trim so windows users can open logs in notepad.
# R146: Add more hooks for tasks to coopt
# R147: BUG: unknown subtasks don't throw errors
# R148: BUG: Can't pass params to subtasks
# R149: BUG: Can't run outside of script's dir
# R200: Added depth-1 directory recursion to descend into "yyyymmdd/" directories
# V0.6: Added more dated directory output types. "yyyy/mm/dd/" and "yyyymmdd/"
# R201: Added a task for ciws hd5
# R202: Added pathname parser
# R203: Improved LDM with pathname parser
# R204: Added array-based filename builder
# R205: Improved subtask parameter support
# R206: Vastly improved path generator
# R207: Added newlines to fileops
# R208: Generate different logfiles based on the task name
# R209: Added a task for asdi.
# R210: Removed max file/dir limit.
# R211: Fix logfile timestamps. (?PM not granular enough)
# R212: Subtask Params now appended to log file name
# R213: All logs now default to in place gzip compression.
# R214: Add 'clobber' support -- Overwrite files. Define <operation>_flags in a taskfile.
# R215: Current log support is only for 'tracing', not Logging or Narration.
# R216: Added 'transparent' compression functions, used in ldm to gzip uncompressed files.
# R217: Fixed equality operator for compress (was integer "-eq", should have been string "==")
# TODO: Check to see if destination file exists. If noclobber, skip 2sec wait & operation.
# TODO: Generate email only if errors occur. Include place of failure.
# TODO: Add depth-3 directory recursion to descend into "yyyy/mm/dd/" directories.
# TODO: Add support for time-based Tar archiving (Last X hours/days of data)
# TODO: Add support for networked filetransfer (scp)
# TODO: Add support for networked multifiletransfer (sftp)
# TODO: Add support for backgrounding networked filetransfer
# TODO: Add support for max number of simultaneous filetransfers
#
# -----------
# End Program Information
# -----------

# -----------
# Variables
# -----------

# -----------
# Error Codes
# -----------


E_BADARGS=65   # Wrong number of arguments passed to script.
E_MISSINGFILE=66 # Couldn't find a file
E_MISMATCH=67 # File size/mtime didn't match

# -----------
# Arrays
# -----------

# -----------
# Strings
# -----------

# -----------
# Paths
# -----------

# Our root operational directory.
main_path_prefix="/workspace/filetasker/home/"
source_path_prefix=${main_path_prefix}
target_path_prefix=${main_path_prefix}

# -----------
# End Variables
# -----------

# Source Common Operations
source ${script_path}/ft_common/ft_common_ops.sh

# -----------
# Main Program
# -----------
#Backup Input Field Separator
OLDIFS=${IFS} 

# Snapshot our cmdline args
ft_args=( ${@} )
task_name=${ft_args[0]}
subtask_name=${ft_args[1]}

# Were we passed a task? If not, bail out now.
MIN_NUM_ARGS=1
# Make sure [ doesn't barf with untyped variable vs String - Quote it!
if [ "${#}" -lt "${MIN_NUM_ARGS}" ]
  then
    echo "   Error: No taskfile specified."
    load_task ft_help; # Unspecified Error
  else
    # Shift the args over past the task & subtask.
    shift 2
    subtask_args=( ${@} )
    # Load Task
    load_task ${task_name}
    # Were we passed a subtask? If not, bail out now.
    if [ "${subtask_name}" == "" ]
      then
        echo "   Error: No subtask specified."
        echo "   Supported Subtasks in $1: ${task_subtasks[@]}"
        quit_filetasker
        exit ${E_BADARGS};
      else
        # Load SubTask
        select_subtask ${subtask_name}
        echo "   Passed parameters to subtask: ${subtask_args[@]}"
    fi    
fi

debug_out "------"
debug_out "LOG SECTION BEGIN"
debug_out "FuncDebug:" ${BASH_SOURCE} "now executing with ${#@} params:" ${@}


# Set up ft environment from ft_common_ops.sh
# This is the main initializer function that sets ft up for a task to be run.
# Currently, changes to source directory. Throws a wobbly if we can't find it.
start_filetasker

# Iterate over the files.
# After start places us in the right directory, we can gather the contents
# into an array and call "task $filename" on each file.
iterate_directories

# Okay, all done, time to quit.
# Brings us back to the directory we started in and blows you kisses goodbye.
quit_filetasker

# Unconditional restore back to the old IFS
IFS=${OLDIFS}
exit 0 # Success
# -----------
# End Main Program
# -----------
