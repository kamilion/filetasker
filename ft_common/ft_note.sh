#!/bin/bash
#  A quick and dirty sqlite notepad in less than 50 lines
#BEGIN TRANSACTION;
#  CREATE TABLE notes (nkey integer primary key,msg text,category text, timeEnter Date);
#  CREATE TRIGGER insert_notes_timeEnter 
#            After insert on notes begin update notes 
#             set timeEnter = Datetime('now','localtime') where rowid=new.rowid; end;
#COMMIT;
script_location=`readlink -f ${BASH_SOURCE}`; script_path=`dirname ${script_location}`; 
SQLITE="${script_path}/ft_sql64"; FILE="${script_path}/../ft_logs/notes.sqlite";

while getopts "ltcf:e:d" opt; do # simple commandline options
 case $opt in
     l ) ${SQLITE} "${FILE}" "select * from notes"; exit 1;;
     t ) ${SQLITE} "${FILE}" "select * from notes where timeEnter >= '"$(date "+%Y-%m-%d")"'"; exit 2;;
     c ) ${SQLITE} "${FILE}" "select category,count(category) from notes group by category"; exit 3;;
     f ) ${SQLITE} "${FILE}" "select * from notes where msg like '${OPTARG}'"; exit 3;;
     e ) MYEXE=$(${OPTARG}); MYEXE=$(echo ${MYEXE}|sed -e s/\'/_/g -e s/\"/__/g); # Strip quotes for sqlite
         ${SQLITE} "${FILE}" "insert into notes (msg) values ('${MYEXE}')";  exit 3;;
     d ) ${SQLITE} "${FILE}" "delete from notes where nkey=(select max(nkey) from notes)"; exit 2;;
  esac
done

shift $(($OPTIND -1)) # Eat the first option now.
if [ "$#" -eq 0 ]; then # Document those options!
 echo -e "A quick and dirty sqlite notepad\n"
 echo "ft_note.sh <option> "
 echo " -l list all notes"
 echo " -t list notes for today"
 echo " -c list categories"
 echo " -f <search string> plaintext search"
 echo " -e <cmd> execute command and add output to notes"
 echo " -d delete last entry"
fi

if [ "$#" -gt 2 ]; then # three or more, probably raw text
  MSG=$(echo ${*}|sed -e s/\'/_/g -e s/\"/__/g) # Strip quotes for sqlite
    ${SQLITE} "${FILE}" "insert into notes (msg) values ('${MSG}')"
else # two or less, probably quoted text
  MSG=$(echo ${1}|sed -e s/\'/_/g -e s/\"/__/g) # Strip quotes for sqlite
    if [ "$#" == 2 ]; then # exactly two, probably quoted text, second's the category
      CATEGORY=$(echo ${2}|sed -e s/\'/_/g -e s/\"/__/g) # Strip quotes for sqlite
      ${SQLITE} "${FILE}" "insert into notes (msg,category) values ('${MSG}','${CATEGORY}')"
    else # exactly one, probably quoted text
      ${SQLITE} "${FILE}" "insert into notes (msg) values ('${MSG}')"
    fi # cannot be zero, otherwise we would have spewed help
fi # End of file
