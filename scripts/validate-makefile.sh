#!/bin/bash

# Function to extract commands from Makefile
extract_commands() {
    grep -oP '^[a-zA-Z_-]+:' $1 | sed 's/://'
}

# Function to check if command has help
has_help() {
    local cmd=$1
    local help_cmd="${cmd}-help"
    grep -q "^[[:space:]]*$help_cmd" $2
}

# Extract commands from the current branch's Makefile and the main branch's Makefile
current_cmds=$(extract_commands "$1")  # First argument is expected to be the current branch's Makefile
main_cmds=$(extract_commands "$2")     # Second argument is expected to be the main branch's Makefile

# Check for new commands and if they have corresponding help
error=0
for cmd in $current_cmds; do
    if ! grep -q "^$cmd$" <<< "$main_cmds"; then
        # This is a new command, check for help
        if ! has_help $cmd "$1"; then  # Check the current branch's Makefile for the help command
            echo "Error: New command '$cmd' added without corresponding help command."
            error=1
        fi
    fi
done

exit $error
