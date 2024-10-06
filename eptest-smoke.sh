#!/bin/bash
#This script tests the Flexify endpoints for both production and test environments.
#Make sure you have configured your virtual endpoint and the AWS profile (key and secret) before running this script.
#For your environment, just change the variables to match your AWS CLI profile, bucket name, and file name
#You can also specify new variables for multiple buckets.
echo "Flexify Endpoint Tester v2.1"
    ts=$(date +"%Y-%m-%d+%H-%M-%S")
    url=https://
    ts1=s3.test.flexify.io
    ts2=s3.azure.test.flexify.io
    prodenv=fl-prod-ep
    testenv=fl-test-ep
    bucket=eugene-test
    file=sample
    logfile=$ts-eptest.log
    errval="ERROR"
    errval2="FAIL"
touch $logfile
adddate() {
    while IFS= read -r line; do
        printf '%s %s\n' "$(date)" "$line";
    done }
errch() {
    local output_message="$1"
    if echo "$output_message" | grep -iq -e "$errval" -e "$errval2"; then
        echo $ts "Error encountered. Check the log for details."
        exit 1
    fi
}
eptest() {
    echo "Testing $1..."
    echo
    echo "Uploading sample file..."
    outul=$(aws s3 --endpoint=$2$1 --profile $3 cp $file s3://$bucket 2>&1)
    echo "$ts-$outul" >> $logfile
    errch "$outul"
    echo
    echo "Downloading sample file..."
    outdl=$(aws s3 --endpoint=$2$1 --profile $3 cp s3://$bucket/$file $file 2>&1)
    echo "$ts-$outul" >> $logfile
    errch "$outdl"
    echo
    echo "Deleting sample file from bucket..."
    outdel=$(aws s3 --endpoint=$2$1 --profile $3 rm s3://$bucket/$file 2>&1)
    echo "$ts-$outdel" >> $logfile
    errch "$outdel"
    echo
}
echo
echo "Creating sample file..."
echo
dd if=/dev/urandom of=$file bs=1 count=1000
echo
sync
for ep in "$ts1" "$ts2"; do
    eptest "$ep" "$url" "$testenv" | tee -a $logfile
    done
echo "Cleaning up..." 
echo 
rm $file 
echo
echo "Test complete. Logs saved to $logfile"
echo