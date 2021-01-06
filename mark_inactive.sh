#!/bin/sh
job=$1
job_status=$(( TOKEN && autorep -j $job) 2>$1)
output=""
check_job=0
for i in $job_status;do
    if [[ $i == "TE" || $i == "FA" || $i == "SU" ]]; then
        output+="JOB STATUS BEFORE ACTIVITY:\n$job_status\n"
        mark_status=$(( TOKEN && sendevent -E CHANGE_STATUS -s INACTIVE -J $job) 2>$1)

        if [ -z $mark_status ]; then 
            output+="JOB PUT TO INACTIVE COMMAND EXECUTED SUCCESSFULLY.\n"
            final_status=$(( TOKEN && autorep -j $job) 2>$1)
            check_status=0
            for j in $final_status; do
                if [[ $j == "IN" ]]; then
                    output+="JOB MARKED INACTIVE SUCCESSFULLY.\n$final_status\n"
                    check_status=1
                fi
            done
            if [[ $check_status == 0 ]]; then
                output+="ERROR: MARKING INACTIVE FAILED. STATUS AFTER MARKING INACTIVE:\n$final_status\n"
            fi 
        else
            output+="ERROR: MARKING INACTIVE COMMAND EXCUTION FAILED.\n$mark_status\n"
        fi 
        check_job=1
    fi 
done
if [[ $check_job == 0 ]]; then
    output+="ERROR: JOB NOT IN SUCCESS OR FAILED OR TERMINATED STATE.\n$job_status\n"
fi 
echo -e $output