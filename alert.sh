#!/bin/bash

# Sys env / paths / etc
# -------------------------------------------------------------------------------------------\
PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
SCRIPT_PATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd); cd $SCRIPT_PATH

HOSTNAME=$(hostname)
HOST_IP=$(ifconfig | grep 192 | awk '{print $2}')
LOG_FILE="$SCRIPT_PATH/log.txt"
PHRASE="Invalid user"
SCRIPT_LOG="$SCRIPT_PATH/script_log.txt"
BACKUP_DIR="$SCRIPT_PATH/backup"

# Checj if BACKUP_DIR exists
function check_backup_dir() {
    if [ ! -d $BACKUP_DIR ]; then
        mkdir -p $BACKUP_DIR
        cp $LOG_FILE $BACKUP_DIR
    fi
}

function save_log_data() {
    
    local dt=$(date)

    # If different LOG_FILE and BACKUP_DIR/log.txt
    local _log_file=$(diff $LOG_FILE $BACKUP_DIR/log.txt)

    if [ ! -z "$_log_file" ]; then

        echo "> LOG_FILE is different from BACKUP_DIR/log.txt"
        
        cp $LOG_FILE $BACKUP_DIR

        # While LOG_FILE is not empty
        while read line; do
            
            # if line conteins PHRASE
            if [[ $line == *$PHRASE* ]]; then

                local invalid_data=$(echo $line | grep "Invalid user" | awk '{print $8" "$10}')
                echo "$dt - Alert! Invalid user auth on $HOSTNAME (with IP: $HOST_IP) - $invalid_data" >> $SCRIPT_LOG
                
            fi
            
        done < $LOG_FILE

    fi

}

check_backup_dir
save_log_data