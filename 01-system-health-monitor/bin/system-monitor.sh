#!/bin/bash

set -euo pipefail

if [[ "($id -u)" -ne 0 ]]; then
    echo "This script can only be executed by Admin"
    exit 1
fi

check_cpu(){
    local cpu_idle=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}' | cut -d'.' -f1)
    local cpu_usage=$((100 - cpu_idle))

    echo "CPU Usage: ${cpu_usage}%"
}

check_memory(){
    # local mem_total=$(free -m | grep "Mem:" | awk '{print $2}')
    # local mem_available=$(free -m | grep "Mem:" | awk '{print $7}')
    # local mem_usage=$((100 - (mem_available / mem_total * 100)))
    # THE ABOVE ONE WAS GIVING IN INTEGER VALUE, SO I USED THE BELOW ONE TO GET THE PERCENTAGE VALUE

    local mem_usage
    mem_usage=$(free -m | awk '/^Mem:/ { printf "%.2f", ($2 - $7) * 100 / $2 }')

    echo "Memory Usage: ${mem_usage}%"
}

check_disk(){
    # local disk_space=$(df -m / | grep -v '^Filesystem' | awk '{print $2}')
    # local disk_used=$(df -m / | grep -v '^Filesystem' | awk '{print $3}')
    # THE ABOVE ONE WAS GIVING IN INTEGER VALUE, SO I USED THE BELOW ONE TO GET THE PERCENTAGE VALUE

    local disk_usage
    disk_usage=$(df -m / | awk 'NR==2 { printf "%.2f", ($3/$2)*100 }')

    if awk "BEGIN {exit !($disk_usage >= $THRESHOLD)}"; then
        echo "Disk Usage: ${disk_usage}% [CRITICAL]"
    else
        echo "Disk Usage: ${disk_usage}%"
    fi
}

check_top_processes(){
    echo "Top 5 Memory consuming Processes"
    ps aux --sort=-%mem | grep -v '^USER' | awk '{printf("%s %s\n", $1, $4)}' | head -n 5
}

main(){
    THRESHOLD=80
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    LOG_FILE="./logs/sys_report_${TIMESTAMP}.log"

    {
        echo "=================================================="
        echo "SYSTEM HEALTH REPORT STARTED"
        echo "=================================================="

        echo ""

        echo "=================================================="
        echo "Date: $(date)"
        echo "$(hostnamectl | grep 'Operating System')"
        echo "Kernel: $(uname -r)"
        echo "=================================================="
            
        echo ""
        
        check_cpu
        check_memory
        check_disk
        check_top_processes

        echo "=================================================="
        echo "SYSTEM HEALTH REPORT COMPLETED"
        echo "=================================================="
    } 2>&1 | tee ${LOG_FILE}

    echo "Report saved to ${LOG_FILE}"
}

main