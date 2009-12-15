# -----------
# FileTasker Database Logging Operations Script
# -----------
# CMDLine Inputs: NIL (Not Executable)
# -----------
# Database Logging Operations Functions
# Sourced by ft_logging_ops.sh
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

SQLITE="${script_path}/ft_common/ft_sql64";

db_log_filename="${script_path}/ft_logs/filetasker.sqlite"

db_create_logs_table="CREATE TABLE main.ft_logs (id INTEGER PRIMARY KEY AUTOINCREMENT, sev INTEGER NOT NULL, time INTEGER NOT NULL, message TEXT NOT NULL);"

# -----------
# Paths
# -----------

# -----------
# End Variables
# -----------

# -----------
# Functions
# -----------

# Start Debugging functions

message_output_to_database() # Logging to database
{ # Inputs: $1 - log_level, $2 - log_timestamp, $3 - log_message
  #db_check_table_exists "ft_logs"; # Does our table exist?
  db_sqlite_query "INSERT INTO main.ft_logs (sev,time,message) VALUES ('${1}','${2}','${3}');";
}

db_sqlite_query() { # Run a SQL Query
  local db_result=$(${SQLITE} "${db_log_filename}" "${1}" 2>&1)
  if [[ "$?" -gt 0 ]]; then echo ${db_result}; return $?; else return $?; fi }

db_does_table_exist() { # Does a SQLLite Table named $1 exist?
  local query="SELECT name FROM sqlite_master WHERE type='table' AND name='$1';"
  local result=$(db_sqlite_query "$query")
  if [[ "$result" == "$1" ]]; then return 0; else return 1; fi }

db_check_table_exists() { db_does_table_exist "${1}";
  if [[ $? -gt 0 ]]; then db_sqlite_query "${db_create_logs_table}"; else echo "TABLE OK"; fi }

# End Debugging functions

# End Main Routines

# -----------
# End Functions
# -----------

# -----------
# Main Program
# -----------

# Output Loader information
if [[ -e "${script_path}/ft_config/ft_config_verbose.on" ]]; then
  echo "  FileTasker Database Logging Module Loaded at ${SECONDS} seconds."; fi
# -----------
# End Main Program
# -----------
