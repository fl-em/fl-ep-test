#!/bin/bash
#This script tests the Flexify endpoints for both production and test environments.
#Make sure you have configured your virtual endpoint and the AWS profile (key and secret) before running this script.
#For your environment, just change the variables to match your AWS CLI profile, bucket name, and file name
#You can also specify new variables for multiple buckets.
echo "Flexify Endpoint Tester v2.1"
    ts=$(date +"%Y-%m-%d+%H-%M-%S")
    url=https://
    ep1=s3.flexify.io
    ep2=s3.eu.flexify.io
    ep3=s3.australiaeast.azure.flexify.io
    ep4=s3.eastus2.azure.flexify.io
    ep5=s3.germanywestcentral.azure.flexify.io
    ep6=s3.us-east-1.aws.flexify.io
    ep7=s3.us-west-1.aws.flexify.io
    ts1=s3.test.flexify.io
    ts2=s3.azure.test.flexify.io
    prodenv=fl-prod-ep
    testenv=fl-test-ep
    bucket=eugene-test
    file=sample
    logfile=$ts-eptest.log
#touch $logfile
adddate() {
    while IFS= read -r line; do
        printf '%s %s\n' "$(date)" "$line";
    done }
errch() {
    if [ $status -ne '0' ]; then
        echo $ts "Error encountered. Check the log for details. Code $status"
        exit 1
    else
        echo "OK."
    fi
}
eptest() {
    local ep="$1"
    local url="$2"
    local profile="$3"
    
    echo "Testing $ep..."
    echo "Uploading sample file..."
    aws s3 --endpoint=$url$ep --profile $profile cp $file s3://$bucket/$file
    status=${PIPESTATUS[0]}
    if [ $status -ne 0 ]; then
        echo "$ts Error encountered during upload. Code $status"
        return 1
    else
        echo "OK."
    fi
    echo "Downloading sample file..."
    aws s3 --endpoint=$url$ep --profile $profile cp s3://$bucket/$file $file
    status=${PIPESTATUS[0]}
    if [ $status -ne 0 ]; then
        echo "$ts Error encountered. Code $status"
        return 1
    else
        echo "OK."
    fi
    echo "Deleting sample file from bucket..."
    aws s3 --endpoint=$2$1 --profile $3 rm s3://$bucket/$file
    status=${PIPESTATUS[0]}
    if [ $status -ne 0 ]; then
        echo "$ts Error encountered. Code $status"
        return 1
    else
        echo "OK."
    fi
}
echo
echo "Creating sample file..."
echo
dd if=/dev/urandom of=$file bs=1 count=1000
echo
sync
for ep in "$ep1" "$ep2" "$ep3" "$ep4" "$ep5" "$ep6" "$ep7"; do
    eptest "$ep" "$url" "$prodenv"
    status=${PIPESTATUS[0]}
    if [ $status -ne 0 ]; then
        echo "Test failed for $ep"
    fi
done
for ep in "$ts1" "$ts2"; do
    eptest "$ep" "$url" "$testenv"
    status=${PIPESTATUS[0]}
    if [ $status -ne 0 ]; then
        echo "Test failed for $ep"
    fi
done
echo "Cleaning up..." 
echo 
rm $file 
echo
echo "Test complete. Logs saved to $logfile"
