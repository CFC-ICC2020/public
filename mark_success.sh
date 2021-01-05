#!/bin/sh
job=$1
job_status=$(( TOKEN && autorep -j $job) 2>$1)
output=""
check_job=0
for i in $job_status;do
    if [[ $i == "IN" || $i == "FA" ]]; then
        output+="JOB STATUS BEFORE ACTIVITY:\n$job_status\n"
        kill_status=$(( TOKEN && sendevent -E KILLJOB -j $job) 2>$1)

        if [ -z $kill_status ]; then 
            output+="JOB KILL COMMAND EXECUTED SUCCESSFULLY.\n"
            mark_status=$(( TOKEN && sendevent -E CHANGE_STATUS -s SUCCESS -J $job) 2>$1)
            
            if [ -z $mark_status ]; then
                output+="MARK SUCCESS COMMAND EXECUTED SUCCESSFULLY.\n"
                final_status=$(( TOKEN && autorep -j $job) 2>$1)
                check_status=0
                for j in $final_status; do
                    if [[ $j == "SU" ]]; then
                        output+="JOB KILLED SUCCESSFULLY.\n$final_status\n"
                        check_status=1
                    fi
                done
                if [[ $check_status == 0 ]]; then
                    output+="ERROR: MARKED SUCCESS FAILED. STATUS AFTER MARKING SUCCESS:\n$final_status\n"
                fi 
            else
                output+="ERROR: MARK SUCESS COMMAND EXCUTION FAILED.\n$mark_status\n"
            fi 
        else
            output+="ERROR: FAILURE IN JOB KILL.\n$kill_status\n"
        fi 
        check_job=1
    fi 
done
if [[ $check_job == 0 ]]; then
    output+="ERROR: JOB NOT IN FAILED OR INACTIVE STATE.\n$job_status\n"
fi 
echo -e $output