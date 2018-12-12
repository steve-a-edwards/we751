#!/bin/bash

# Steve Edwards, IBM DataPower Specialist, November 2018.
# 
# Script to send a curl command a variable number of times on a Linux system.
# SLM exercise 6 - DataPower course WE751
# This script provides an alternative to the use of SOAPUI as described in the
# exercise description.
# When using SOAPUI, much of the activity is hidden away.
# This script outputs more information on what is in the responses:
# - HTTP response codes (terminal)
# - timings of request / response (terminal)
# - all response contents (file)
# See bottom of this file for usage.

# THE FILE USED AS CONTENT OF REQUEST:
FILE=/usr/labfiles/dp/BookingService/BookingRequest.xml

# COLOURS OUTPUT TO THE TERMINAL:
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# ====================================================================================================================================================
# FUNCTION TO SEND REQUEST, WAIT FOR RESPONSE, OUTPUT TO TERMINAL AND SCREEN:
function send_using_curl {
# USED FOR TIMING RESPONSE TIME:
  SECONDS=0
# OUTPUT TO TERMINAL:
  echo "*********** Sending request    #$3 of $4  *************************************"
  date +'%H:%M:%S'
# https://ec.haxx.se/usingcurl-verbose.html
# https://stackoverflow.com/questions/45601115/curl-output-append-to-a-file-without-redirection
# MAKE CALL TO SERVICE:
  STATUSCODE=$(curl --silent --output >(cat >> $RESPONSES_FILE) --data-binary @$FILE http://$1:$2/ -H 'Content-Type: text/xml' --write-out '%{http_code}')
# RESPONSE CONTENT OUTPUT TO FILE:
  echo -e "\n===================== Response above for request number $3 =====================" | tee -a $RESPONSES_FILE >/dev/null
  tee -a $RESPONSES_FILE<<<""  >/dev/null
# OUTPUT TO TERMINAL:
  duration=$SECONDS
  echo "*********** Receiving response #$3 of $4 after $SECONDS seconds"
  STATUS_CODE_TEXT="Status code $STATUSCODE"
  if [ $STATUSCODE -eq "500" ]
  then
    STATUS_CODE_TEXT="${RED}${STATUS_CODE_TEXT} - REJECTED !!!${NC}"
  else
    STATUS_CODE_TEXT="${GREEN}${STATUS_CODE_TEXT} - ACCEPTED !!!${NC}"
  fi
  echo -e $STATUS_CODE_TEXT
  date +%H:%M:%S
  echo "=============================================================================="
}
# ====================================================================================================================================================
# USED TO TIME OVERALL DURATION:
SECONDS=0
# THERE SHOULD BE 4 PARAMETER TO CALL TO THIS SCRIPT (SEE BELOW):
if [ $# -eq 4 ]
# THEN:
then
# SET UP LOOP COUNTERS FROM PARAMETERS:
COUNT=$3
# SUFFIX may be 's' for seconds (the default), 'm' for minutes, 'h' for hours or 'd' for days. 
# NUMBER may be an arbitrary floating point number, e.g. "1s"
DELAY=$4

# THE CONTENT OF ALL OF THE RESPONSES WILL BE APPENDED TO THIS FILE:
RESPONSES_FILE=`date +%H-%M-%S.txt`
touch $RESPONSES_FILE
echo $RESPONSES_FILE

INDEX=1
while [[ $INDEX -le $COUNT ]]
do
# FOLLOWING LINE MAKES CALL BUT DOES NOT WAIT FOR RESPONSE:
	send_using_curl $1 $2 $INDEX $COUNT &
	sleep $DELAY
	(( INDEX += 1 ))
done
# WORK OUT DURATION OF ALL THE REQUESTS BEING SENT (NOT RESPONSES):
duration=$SECONDS
echo "==============================================================================="
echo "Completed sending $COUNT requests in $duration seconds. Waiting for all responses ..."
echo "==============================================================================="
# NOW WAIT UNTIL ALL RESPONSES RECEIVED:
wait
# WORK OUT DURATION OF ALL THE REQUESTS AND RESPONSES:
duration=$SECONDS
# OUTPUT TO TERMINAL:
echo "Completed receiving all $COUNT responses in $duration seconds"
echo "See combined responses in file $RESPONSES_FILE"
echo "ALL DONE"
# END OF NORMAL PROCESSING.

# ELSE: NOT CORRECT NUMBER OF PARAMETERS IN CALL TO THIS SCRIPT:
else
  echo
  echo "Usage - requires 4 parameters."
  echo "Example:"
  echo "   ./driveSLM-WE751.sh 192.168.0.101 12011 10 1s"
  echo "Parameter 1: host to receive requests"
  echo "Parameter 2: port to receive requests"
  echo "Parameter 3: number of requests to be made"
  echo "Parameter 4: delay between successive requests"
fi
