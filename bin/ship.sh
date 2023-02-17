##!/usr/bin/env bash
# Author: Mr. Charkuils

while getopts "t:m:u:f:h:c:s:d:b:l:" ARG; do
  case $ARG in
    t)
      SHIP_TIMEOUT=$OPTARG
      ;;
    m)
      SHIP_METHOD=$OPTARG
      ;;
    u)
      SHIP_URL=$OPTARG
      ;;
    f)
      SHIP_FILE=$OPTARG
      ;;
    h)
      SHIP_SHOW_HEADERS=$OPTARG
      ;;
    c)
      SHIP_HEADERS=$OPTARG
      ;;
    s)
      SHIP_SAVE=$OPTARG
      ;;
    d)
      SHIP_OUTPUT_FOLDER=$OPTARG
      ;;
    b)
      SHIP_BODY=$OPTARG
      ;;
    l)
      SHIP_LOG_FILE=$OPTARG
      ;;
  esac
done

if [ $SHIP_SAVE = "true" ]; then
    # If output folder does not exist, then create it
    [[ -d $SHIP_OUTPUT_FOLDER ]] || mkdir -p $SHIP_OUTPUT_FOLDER
fi

# Check if body is included
[[ ${#SHIP_BODY} -gt 0 ]] && SHIP_BODY="-d '${SHIP_BODY}'"

# Headers options
if [ $SHIP_SHOW_HEADERS = 'res' ]; then
    SHOW_RES_HEAD="-i"
elif [ $SHIP_SHOW_HEADERS = 'all' ]; then
    SHOW_RES_HEAD="-v"
    FILTER_SED="| sed '/^* /d; /bytes data]$/d; s/> //; s/< //'"
fi
# Remove Windows chars
FILTER_TR="| tr '\015' '\t'"

# Custom cUrl
CUSTOM_CURL="curl -s $SHOW_RES_HEAD --connect-timeout $SHIP_TIMEOUT $SHIP_HEADERS $SHIP_BODY \
-w '\nSHIP_CODE_TIME=%{http_code},%{time_total}\n%{onerror}ERROR %{errormsg}' \
-X $SHIP_METHOD '$SHIP_URL' 2>&1 $FILTER_SED $FILTER_TR > $SHIP_FILE"

eval $CUSTOM_CURL

# Store status code and time
touch /tmp/ship_code_time_tmp
grep 'SHIP_CODE_TIME' $SHIP_FILE | sed 's/SHIP_CODE_TIME=//g' > /tmp/ship_code_time_tmp

# Extract data response
RES_LINE=$(grep -v -e '^$' $SHIP_FILE | grep -B1 'SHIP_CODE_TIME' | grep -v 'SHIP_CODE_TIME') 

# Extract SHIP_CODE_TIME
SHIP_CODE_TIME_LINE_NR=$(grep -v -e '^$' $SHIP_FILE | grep -n 'SHIP_CODE_TIME' | cut -f1 -d:)

# Log error if curl fails and exit
if [[ -z $SHIP_CODE_TIME_LINE_NR ]]; then
    echo -e "[ERROR] [$(date '+%D-%T')]:" >> $SHIP_LOG_FILE
    echo "CURL ==> $CUSTOM_CURL" >> $SHIP_LOG_FILE
    cat $SHIP_FILE >> $SHIP_LOG_FILE
    rm $SHIP_FILE
    exit 1
fi

# Create ramdom temporary file
TMP_RES=$(mktemp)

# Format response
format_response() {
    # Format response
    TMP_RES_FILE=$(mktemp)
    echo $RES_LINE | $@ > $TMP_RES_FILE
        
    # Extract line numbers to delete
    RESPONSE_LINE_NR=$(($SHIP_CODE_TIME_LINE_NR - 1))
    FORMATTED_RESPONSE_LINE_NR=$(($RESPONSE_LINE_NR - 1))
        
    # Delete lines 
    sed "${RESPONSE_LINE_NR},${SHIP_CODE_TIME_LINE_NR}d" $SHIP_FILE | sed '/SHIP_CODE_TIME/d' > $TMP_RES
        
    # Paste formatted response
    if [ $SHIP_SHOW_HEADERS = 'none' ]; then
        cat $TMP_RES_FILE > $SHIP_FILE
    else
        sed "${FORMATTED_RESPONSE_LINE_NR} r ${TMP_RES_FILE}" $TMP_RES > $SHIP_FILE
    fi

    rm $TMP_RES_FILE
}

# Check if response is unformatted
if [ ${#RES_LINE} -gt 2 ] && ([[ $RES_LINE = \{* ]] || [[ $RES_LINE = \[* ]]); then
    # JSON
    format_response "jq"
elif [[ $RES_LINE = *"<?xml"* ]]; then
    # XML
    format_response "tidy -xml -quiet"
elif [[ $RES_LINE = *"<html>"* ]]; then
    # HTML
    format_response "tidy -quiet"
else
    # Delete SHIP_CODE_TIME
    sed "${SHIP_CODE_TIME_LINE_NR}d" $SHIP_FILE | sed '/SHIP_CODE_TIME/d' > $TMP_RES
    cat $TMP_RES > $SHIP_FILE
fi

# Delete random temporary file
rm $TMP_RES


