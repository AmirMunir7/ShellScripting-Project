#!/bin/bash



logFile="bank_server.log"

reportFile="full_report.txt"



# Check Log File Exists

check_log_file() {

    if [ ! -f "$logFile" ]; then

        echo "Error: $logFile missing or doesn't exist."

        exit 1

    fi

}



check_log_file



# Check Username Input

check_username() {

    input="$1"

    cleandInput=$(echo "$input" | tr -d ' ')

    

    while [ -z "$cleandInput" ]; do

        read -p "Enter username: " input

        cleandInput=$(echo "$input" | tr -d ' ')

    done



    echo "$input"

}



# 1. Failed Login Report

failed_login_report() {

    echo -e "\n---Failed Login Report---\n"

    failedLines=$(grep "\[ERROR\].*\[AUTH\].*Failed login attempt" "$logFile")



    if [ -z "$failedLines" ]; then

        echo "Total failed login attempts: 0"

        return

    fi



    total=$(echo "$failedLines" | wc -l | tr -d ' ')

    echo -e "Total failed login attempts: $total \n"



    echo "Failed attempts grouped by IP:"

    echo "$failedLines" | cut -d'[' -f6 | cut -d']' -f1 | sort | uniq -c



    echo "Failed attempts grouped by USER:"

    echo "$failedLines" | cut -d'[' -f5 | cut -d']' -f1 | sort | uniq -c



    echo -e "\nPossible brute force IP addresses:"

    echo "$failedLines" | cut -d'[' -f6 | cut -d']' -f1 | sort | uniq -c | tr -s ' ' | grep -E "^ ([3-9]|[1-9][0-9]+)" | sed 's/^ //' | sed 's/\([^ ]*\) \(.*\)/\2 -> \1 failed attempts/'

}



# 2. Query Activity Summary

query_activity_summary() {

    echo -e "\n---Query Activity Summary---\n"

    totalQueries=$(grep "\[QUERY\]" "$logFile" | wc -l | tr -d ' ')



    queryLines=$(grep "\[QUERY\]" "$logFile")



    selectCount=$(echo "$queryLines" | grep -i "SELECT" | wc -l | tr -d ' ')

    updateCount=$(echo "$queryLines" | grep -i "UPDATE" | wc -l | tr -d ' ')

    insertCount=$(echo "$queryLines" | grep -i "INSERT" | wc -l | tr -d ' ')

    deleteCount=$(echo "$queryLines" | grep -i "DELETE" | wc -l | tr -d ' ')



    echo -e "\nTotal QUERY events: $totalQueries\n"

    echo -e "Query types:\nSELECT : $selectCount\nUPDATE : $updateCount\nINSERT : $insertCount\nDELETE : $deleteCount\n"

}



# 3. Slow Query Detector

slow_query_detector() {

    echo -e "\n---Slow Query Detector---\n"

    slowQueries=$(grep "\[WARNING\].*\[QUERY\].*Slow query" "$logFile")

    

    if [ -z "$slowQueries" ]; then

        echo "No slow queries found."

        return

    fi



    for line in $(echo "$slowQueries" | tr ' ' '_'); do

        cleanLine=$(echo "$line" | tr '_' ' ')     

        user=$(echo "$cleanLine" | cut -d'[' -f5 | cut -d']' -f1)

        message=$(echo "$cleanLine" | cut -d'-' -f2- | cut -c2-)

        execTime=$(echo "$message" | grep -o "execution_time=[^ ]*" | cut -d'=' -f2)

        if [ -z "$execTime" ]; then

            execTime="N/A"

        fi



        echo -e "User: $user\nExecution Time: $execTime\nQuery: $message\n------------------------------------"

    done

}



# 4. Transaction Report

transaction_report() {

    echo -e "\n---Transaction Report---\n"

    transactionLines=$(grep "\[TRANSACTION\]" "$logFile")



    if [ -z "$transactionLines" ]; then

        echo "No transaction events found."

        return

    fi



    depositCount=$(echo "$transactionLines" | grep -i "Deposit" | wc -l | tr -d ' ')

    withdrawalCount=$(echo "$transactionLines" | grep -i "Withdrawal" | wc -l | tr -d ' ')

    declinedCount=$(echo "$transactionLines" | grep -i "Declined transaction" | wc -l | tr -d ' ')

    rollbackCount=$(echo "$transactionLines" | grep -i "Rollback" | wc -l | tr -d ' ')



    totalDeposited=0

    for val in $(echo "$transactionLines" | grep -i "Deposit" | grep -o "amount=[0-9]*" | cut -d'=' -f2); do

        totalDeposited=$((totalDeposited + val))

    done



    totalWithdrawn=0

    for val in $(echo "$transactionLines" | grep -i "Withdrawal" | grep -o "amount=[0-9]*" | cut -d'=' -f2); do

        totalWithdrawn=$((totalWithdrawn + val))

    done



    echo -e "Number of deposits: $depositCount\nNumber of withdrawals: $withdrawalCount\nNumber of declined transactions: $declinedCount\nNumber of rollbacks: $rollbackCount\n\nTotal deposited amount: $totalDeposited\nTotal withdrawn amount : $totalWithdrawn"

}



# 5. Critical Events Report

critical_events_report() {

    echo -e "\n---Critical Events Report---\n"

    criticalLines=$(grep "\[CRITICAL\]" "$logFile")



    if [ -z "$criticalLines" ]; then

        echo "No critical events found."

        return

    fi



    totalCritical=$(echo "$criticalLines" | wc -l | tr -d ' ')

    echo -e "Total critical events: $totalCritical\n"



    for line in $(echo "$criticalLines" | tr ' ' '_'); do

        cleanLine=$(echo "$line" | tr '_' ' ')



        timestamp=$(echo "$cleanLine" | cut -d'[' -f2 | cut -d']' -f1)

        module=$(echo "$cleanLine" | cut -d'[' -f7 | cut -d']' -f1)

        message=$(echo "$cleanLine" | cut -d'-' -f2- | cut -c2-)



        echo -e "Timestamp: $timestamp\nModule: $module\nMessage: $message\n------------------------------------"

    done

}



# 6. User Activity Report

user_activity_report() {

    echo -e "\n---User Activity Report---\n"



    username=$(check_username "$1")

    userLines=$(grep "\[$username\]" "$logFile")



    if [ -z "$userLines" ]; then

        echo "User '$username' not found."

        return

    fi



    totalActions=$(echo "$userLines" | wc -l | tr -d ' ')



    echo -e "\nUser: $username\nTotal actions: $totalActions\n\nActivity:\n"



    for line in $(echo "$userLines" | sort | tr ' ' '_'); do

        cleanLine=$(echo "$line" | tr '_' ' ')



        timestamp=$(echo "$cleanLine" | cut -d'[' -f2 | cut -d']' -f1)

        logLevel=$(echo "$cleanLine" | cut -d'[' -f3 | cut -d']' -f1)

        sessionVal=$(echo "$cleanLine" | cut -d'[' -f4 | cut -d']' -f1)

        ipVal=$(echo "$cleanLine" | cut -d'[' -f6 | cut -d']' -f1)

        moduleVal=$(echo "$cleanLine" | cut -d'[' -f7 | cut -d']' -f1)

        messageVal=$(echo "$cleanLine" | cut -d'-' -f2- | cut -c2-)



        echo -e "Timestamp : $timestamp\nLevel: $logLevel\nSession: $sessionVal\nIP: $ipVal\nModule: $moduleVal\nAction: $messageVal\n------------------------------------"

    done

}

# 7. Login/Logout Session Report

session_report() {

    echo -e "\n---Login/Logout Session Report---\n"





    sessions=$(grep -o "\[SESSION_[A-Za-z0-9_]*\]" "$logFile" | sort | uniq)



    for session in $sessions

    do

        echo "Session: $session"





        login_line=$(grep -F "$session" "$logFile" | grep "Successful login" | head -n 1)

        logout_line=$(grep -F "$session" "$logFile" | grep "Logout successful" | tail -n 1)





        login_timestamp=$(echo "$login_line" | cut -d'[' -f2 | cut -d']' -f1)

        logout_timestamp=$(echo "$logout_line" | cut -d'[' -f2 | cut -d']' -f1)





        if [ -z "$login_timestamp" ]; then

            echo "Login: Not available"

        else

            login_time=$(echo "$login_timestamp" | cut -d' ' -f2)

            echo "Login: $login_time"

        fi





        if [ -z "$logout_timestamp" ]; then

            echo "Logout: Not available"

        else

            logout_time=$(echo "$logout_timestamp" | cut -d' ' -f2)

            echo "Logout: $logout_time"



            if [ -n "$login_timestamp" ]; then



                login_seconds=$(date -d "$login_timestamp" +%s)

                logout_seconds=$(date -d "$logout_timestamp" +%s)



                duration=$((logout_seconds - login_seconds))



                hours=$((duration / 3600))

                minutes=$(((duration % 3600) / 60))

                seconds=$((duration % 60))



                echo "Duration: $hours hours $minutes minutes $seconds seconds"

            fi

        fi



        echo "------------------------------------"

    done

}

# 8. Events-per-Hour Report

events_per_hour_report() {

    echo -e "\n---Events-per-Hour Report---\n"



    hourLines=$(cut -d'[' -f2 "$logFile" | cut -d']' -f1 | cut -d' ' -f2 | cut -d':' -f1 | sort | uniq -c)



    for item in $(echo "$hourLines" | tr -s ' ' | tr ' ' '_'); do

        cleanItem=$(echo "$item" | tr '_' ' ')

        countVal=$(echo "$cleanItem" | cut -d' ' -f2)

        hourVal=$(echo "$cleanItem" | cut -d' ' -f3)



        if [ -n "$hourVal" ]; then

            printf "%s:00 - %s:59 : %d events\n" "$hourVal" "$hourVal" "$countVal"

        fi

    done

}



# 9. General Log Summary

general_log_summary() {

    echo -e "\n---General Log Summary---\n"



    totalEvents=$(wc -l < "$logFile" | tr -d ' ')



    infoCount=$(grep "\[INFO\]" "$logFile" | wc -l | tr -d ' ')

    warningCount=$(grep "\[WARNING\]" "$logFile" | wc -l | tr -d ' ')

    errorCount=$(grep "\[ERROR\]" "$logFile" | wc -l | tr -d ' ')

    criticalCount=$(grep "\[CRITICAL\]" "$logFile" | wc -l | tr -d ' ')



    busiestInfo=$(cut -d'[' -f7 "$logFile" | cut -d']' -f1 | grep -v '^$' | sort | uniq -c | sort -nr | head -n 1)



    busiestCount=$(echo "$busiestInfo" | tr -s ' ' | cut -d' ' -f2)

    busiestModule=$(echo "$busiestInfo" | tr -s ' ' | cut -d' ' -f3)



    echo -e "Total log events: $totalEvents\n\nEvents by log level:\nINFO: $infoCount\nWARNING: $warningCount\nERROR: $errorCount\nCRITICAL: $criticalCount\n\nBusiest module: $busiestModule\nNumber of events: $busiestCount"

}



# 10. Run All Reports

run_all_reports() {

    echo -e "\n---Run All Reports---\n"



    read -p "Enter username for User Activity Report: " reportUser



    {

        echo -e "\n---BANK DATABASE SERVER FULL REPORT---\n"

        failed_login_report

        echo

        query_activity_summary

        echo

        slow_query_detector

        echo

        transaction_report

        echo

        critical_events_report

        echo

        user_activity_report "$reportUser"

        echo

        session_report

        echo

        events_per_hour_report

        echo

        general_log_summary

        echo

        echo -e "\n^^^END OF REPORT^^^\n"

    } > "$reportFile"



    echo -e "\nFull report saved to: $reportFile"

}



# Main Menu

while true; do

    echo -e "\nBank Analyzer\n"

    echo "1. Failed Login Report"

    echo "2. Query Activity Summary"

    echo "3. Slow Query Detector"

    echo "4. Transaction Report"

    echo "5. Critical Events Report"

    echo "6. User Activity Report"

    echo "7. Login/Logout Session Report"

    echo "8. Events-per-Hour Report"

    echo "9. General Log Summary"

    echo "10. Run All Reports"

    echo "0. Exit"



    read -p "Enter your choice: " choice



    case "$choice" in

        1) failed_login_report ;;

        2) query_activity_summary ;;

        3) slow_query_detector ;;

        4) transaction_report ;;

        5) critical_events_report ;;

        6) user_activity_report ;;

        7) session_report ;;

        8) events_per_hour_report ;;

        9) general_log_summary ;;

        10) run_all_reports ;;

        0) echo "Goodbye!"; exit 0 ;;

        *) echo "Invalid choice. Retry" ;;

    esac



    echo

done 

