#!/bin/sh
job=$1
job_status=$(( TOKEN && autorep -j $job) 2>$1)
output=""
check_job=0
for i in $job_status;do
    if [[ $i == "OH" || $i == "FA" || $i == "SU" || $i == "TE" || $i == "OI" || $i == "AC" || $i == "IN" ]]; then
        output+="JOB STATUS BEFORE ACTIVITY:\n$job_status\n"
        hold_status=$(( TOKEN && sendevent -E JOB_ON_ICE -J $job) 2>$1)

        if [ -z $ice_status ]; then 
            output+="JOB PUT TO ON-ICE COMMAND EXECUTED SUCCESSFULLY.\n"
            final_status=$(( TOKEN && autorep -j $job) 2>$1)
            check_status=0
            for j in $final_status; do
                if [[ $j == "OI" ]]; then
                    output+="JOB PUT TO ON-ICE SUCCESSFULLY.\n$final_status\n"
                    check_status=1
                fi
            done
            if [[ $check_status == 0 ]]; then
                output+="ERROR: PUTTING ON-ICE FAILED. STATUS AFTER PUTTING ON-ICE:\n$final_status\n"
            fi 
        else
            output+="ERROR: PUTTING ON-ICE COMMAND EXCUTION FAILED.\n$hold_status\n"
        fi 
        check_job=1
    fi 
done
if [[ $check_job == 0 ]]; then
    output+="ERROR: JOB IN STARTING OR RUNNING STATE.\n$job_status\n"
fi 
echo -e $output