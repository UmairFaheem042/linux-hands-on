#!/bin/bash

set -euo pipefail

# find logs
find_old_logs(){
    # find logs (files) in a directory (/var/log/myApp) -- no subdirectory
    find -type f /var/log/myApp -name "*.log"

    # find logs older than 7 days => use mtime option
    find -type f /var/log/myApp -name "*.log" -mtime +7
}

# convert founded logs to .tar
convert_to_tar(){
    # tar [flags] destinationFileName sourceFileName
}

# convert .tar to .gz
conver_to_gz(){}

# convert .tar then .gz in one command
conver_to_tar_gz(){}

# verify files created and delete the original
verify_and_delete(){}

# main entry point
main(){}

main