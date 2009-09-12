#!/bin/sh
# -----------
# FileTasker Logging Operations Script
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

log_severity_level=DEBUG
logfile_path="${script_path}/ft_logs/"
log_filename_debug="${logfile_path}filetasker-debug.log"
log_filename_info="${logfile_path}filetasker-info.log"
log_filename_error="${logfile_path}filetasker-error.log"
log_filesize_maximum=1000     

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

function rotate_log_file() {
    log_file_to_rotate=$1

    length=`expr length $log_file_to_rotate`
    length=`expr $length+1`
    max=0
    for files in ${log_file_to_rotate}.[0-9]*
    do 
        if [ -f "$files" ]; then 
            num=`echo ${files:$length}`
            if [ $num -gt $max ]; then
                max=$num
            fi
        fi
    done

    maxarrayLen=0
    zero=0
    for ((i=$max;i>0;i-=1))
    do
        #echo "log_file_to_rotate - ${log_file_to_rotate}.${i}"

        if [ -f "$log_file_to_rotate.$i" ]; then 
            tmp=$log_file_to_rotate.$i
            tmpno=`expr $i + 1`

            mv $tmp "$log_file_to_rotate.$tmpno" ; # > /dev/null 2>&1
            maxarrayLen=`expr $maxarrayLen + 1`
        fi
    done
    mv $log_file_to_rotate "${log_file_to_rotate}.1" > /dev/null 2>&1
    touch $log_file_to_rotate
}

function check_log_file_size() {
    logfile_to_check=$1
    if [ -s $logfile_to_check ]; then
    	FILESIZE=$(stat -c%s "$logfile_to_check")
    	log_filesize_maximum_bytes=$(($log_filesize_maximum * 1000))
        #echo "----${FILESIZE}----${log_filesize_maximum_bytes}"
    	if [ $FILESIZE -gt $log_filesize_maximum_bytes ]; then
        	rotate_log_file $logfile_to_check
    	fi
    fi
}

function log_output() {
    check_log_file_size $log_filename_debug
    check_log_file_size $log_filename_info
    check_log_file_size $log_filename_error

    if [ $# -eq 2 ]; then

        case "${1}" in
            ERROR )
                if [ "$log_severity_level" = "STDOUT" ]; then 
                   echo "$1 [`date +'%d-%b-%y %T'`] $2" | tee -a $log_filename_debug $log_filename_info $log_filename_error
                else
                   echo "$1 [`date +'%d-%b-%y %T'`] $2" | tee -a $log_filename_debug $log_filename_info $log_filename_error >> /dev/null
                fi
                ;;
            INFO )
                if [ "$log_severity_level" = "STDOUT" ]; then 
                   echo "$1 [`date +'%d-%b-%y %T'`] $2" | tee -a $log_filename_debug $log_filename_info
                elif [ "$log_severity_level" = "INFO" -o "$log_severity_level" = "DEBUG" ]; then 
                    echo "$1 [`date +'%d-%b-%y %T'`] $2" | tee -a $log_filename_debug $log_filename_info >> /dev/null
                fi
                ;;
            DEBUG )
                if [ "$log_severity_level" = "STDOUT" ]; then 
                   echo "$1 [`date +'%d-%b-%y %T'`] $2" | tee -a $log_filename_debug
                elif [ "$log_severity_level" = "DEBUG" ]; then 
                    echo "$1 [`date +'%d-%b-%y %T'`] $2" | tee -a $log_filename_debug >> /dev/null
                fi
                ;;
            *)
                if [ "$log_severity_level" = "STDOUT" ]; then 
                   echo "$DEBUG [`date +'%d-%b-%y %T'`] $1 - $2" | tee -a $log_filename_debug
                elif [ "$log_severity_level" = "DEBUG" ]; then 
                    echo "DEBUG [`date +'%d-%b-%y %T'`] $1 - $2" | tee -a $log_filename_debug >> /dev/null
                fi
                ;;
        esac
    else
        if [ "$log_severity_level" = "STDOUT" ]; then 
           echo "$1 [`date +'%d-%b-%y %T'`] $@" | tee -a $log_filename_debug
        elif [ "$log_severity_level" = "DEBUG" ]; then 
            echo "DEBUG [`date +'%d-%b-%y %T'`] $@" | tee -a $log_filename_debug >> /dev/null
        fi
    fi
}

function INFO() {
    log_message=$@
    IFS=$'/'
    file_source_path_full=${BASH_SOURCE[1]}
    set -- $file_source_path_full
    path_array=( $file_source_path_full )
    unset IFS
    path_array_length=${#path_array[@]}
    file_source=${path_array[$path_array_length-1]}
    log_output "INFO" " ${file_source}:${FUNCNAME[1]}:${BASH_LINENO[0]} - $log_message"
}

function DEBUG() {
    log_message=$@
    IFS=$'/'
    file_source_path_full=${BASH_SOURCE[1]}
    set -- $file_source_path_full
    path_array=( $file_source_path_full )
    unset IFS
    path_array_length=${#path_array[@]}
    file_source=${path_array[$path_array_length-1]}
    log_output "DEBUG" "${file_source}:${FUNCNAME[1]}:${BASH_LINENO[0]} - $log_message"
}

function ERROR() {
    log_message=$@
    IFS=$'/'
    file_source_path_full=${BASH_SOURCE[1]}
    set -- $file_source_path_full
    path_array=( $file_source_path_full )
    unset IFS

    path_array_length=${#path_array[@]}
    file_source=${path_array[$path_array_length-1]}
    log_output "ERROR" "${file_source}:${FUNCNAME[1]}:${BASH_LINENO[0]} - $log_message"
}


