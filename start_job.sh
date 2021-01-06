#!/bin/sh
job=$1
job_status=$(( TOKEN && autorep -j $job) 2>$1)
output=""
check_job=0
for i in $job_status;do
    if [[ $i == "IN" || $i == "FA" || $i == "SU" ]]; then
        output+="JOB STATUS BEFORE ACTIVITY:\n$job_status\n" 
        start_status=$(( TOKEN && sendevent -E STARTJOB -j $job) 2>$1)

        if [ -z $start_status ]; then 
            output+="START COMMAND EXECUTED SUCCESSFULLY.\n"
            final_status=$(( TOKEN && autorep -j $job) 2>$1)
            check_status=0
            for j in $final_status; do
                if [[ $j == "ST" || $j == "RU" ]]; then
                    output+="JOB STARTED SUCCESSFULLY.\n$final_status\n"
                    check_status=1
                fi
            done
            if [[ $check_status == 0 ]]; then
                sleep 1m
                new_status=$(( TOKEN && autorep -j $job) 2>$1)
                
                if [[ $new_status == $job_status ]]; then
                    output+="ERROR: JOB START FAILED. STATUS AFTER STARTING:\n$new_status\n"
                else
                    output+="JOB STARTED SUCCESSFULLY.\n$new_status\n"
                fi
            fi 
        else
            output+="ERROR: START COMMAND EXCUTION FAILED.\n$start_status\n"
        fi 
        check_job=1
    fi 
done
if [[ $check_job == 0 ]]; then
    output+="ERROR: JOB NOT IN FAILED OR INACTIVE OR SUCCESS STATE.\n$job_status\n"
fi 
echo -e $output