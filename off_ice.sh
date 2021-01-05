#!/bin/sh
job=$1
job_status=$(( TOKEN && autorep -j $job) 2>$1)
output=""
check_job=0
for i in $job_status;do
    if [[ $i == "OI" ]]; then
        output+="JOB STATUS BEFORE ACTIVITY:\n$job_status\n"
        ice_status=$(( TOKEN && sendevent -E JOB_OFF_ICE -J $job) 2>$1)

        if [ -z $ice_status ]; then 
            output+="JOB PUT TO OFF-ICE COMMAND EXECUTED SUCCESSFULLY.\n"
            final_status=$(( TOKEN && autorep -j $job) 2>$1)
            check_status=0
            for j in $final_status; do
                if [[ $j == "ST" || $j == "RU" || $j == "FA" || $j == "SU" || $j == "TE" || $j == "OH" || $j == "AC" || $j == "IN" ]]; then
                    output+="JOB PUT TO OFF-ICE SUCCESSFULLY.\n$final_status\n"
                    check_status=1
                fi
            done
            if [[ $check_status == 0 ]]; then
                output+="ERROR: PUTTING OFF-ICE FAILED. STATUS AFTER PUTTING OFF-HOLD:\n$final_status\n"
            fi 
        else
            output+="ERROR: PUTTING OFF-ICE COMMAND EXCUTION FAILED.\n$ice_status\n"
        fi 
        check_job=1
    fi 
done
if [[ $check_job == 0 ]]; then
    output+="ERROR: JOB NOT IN ON-ICE STATE.\n$job_status\n"
fi 
echo -e $output