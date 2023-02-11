##!/usr/bin/env bash
# Author: Mr. Charkuils

while getopts "t:m:u:f:h:c:s:d:b:l:" ARG; do
  case $ARG in
    t)
      CAFE_TIMEOUT=$OPTARG
      ;;
    m)
      CAFE_METHOD=$OPTARG
      ;;
    u)
      CAFE_URL=$OPTARG
      ;;
    f)
      CAFE_FILE=$OPTARG
      ;;
    h)
      CAFE_SHOW_HEADERS=$OPTARG
      ;;
    c)
      CAFE_HEADERS=$OPTARG
      ;;
    s)
      CAFE_SAVE=$OPTARG
      ;;
    d)
      CAFE_OUTPUT_FOLDER=$OPTARG
      ;;
    b)
      CAFE_BODY=$OPTARG
      ;;
    l)
      CAFE_LOG_FILE=$OPTARG
      ;;
  esac
done

if [ $CAFE_SAVE = "true" ]; then
    # If output folder does not exist, then create it
    [[ -d $CAFE_OUTPUT_FOLDER ]] || mkdir -p $CAFE_OUTPUT_FOLDER
fi

# Check if body is included
[[ ${#CAFE_BODY} -gt 0 ]] && CAFE_BODY="-d '${CAFE_BODY}'"

# Headers options
if [ $CAFE_SHOW_HEADERS = 'res' ]; then
    SHOW_RES_HEAD="-i"
elif [ $CAFE_SHOW_HEADERS = 'all' ]; then
    SHOW_RES_HEAD="-v"
    FILTER_SED="| sed '/^* /d; /bytes data]$/d; s/> //; s/< //'"
fi
# Remove Windows chars
FILTER_TR="| tr '\015' '\t'"

# Custom cUrl
CUSTOM_CURL="curl -s $SHOW_RES_HEAD --connect-timeout $CAFE_TIMEOUT $CAFE_HEADERS $CAFE_BODY \
-w '\nCAFE_CODE_TIME=%{http_code},%{time_total}\n%{onerror}ERROR %{errormsg}' \
-X $CAFE_METHOD '$CAFE_URL' 2>&1 $FILTER_SED $FILTER_TR > $CAFE_FILE"

eval $CUSTOM_CURL

# Store status code and time
touch /tmp/cafe_code_time_tmp
grep 'CAFE_CODE_TIME' $CAFE_FILE | sed 's/CAFE_CODE_TIME=//g' > /tmp/cafe_code_time_tmp

# Extract data response
RES_LINE=$(grep -v -e '^$' $CAFE_FILE | grep -B1 'CAFE_CODE_TIME' | grep -v 'CAFE_CODE_TIME') 

# Extract CAFE_CODE_TIME
CAFE_CODE_TIME_LINE_NR=$(grep -v -e '^$' $CAFE_FILE | grep -n 'CAFE_CODE_TIME' | cut -f1 -d:)

# Log error if curl fails and exit
if [[ -z $CAFE_CODE_TIME_LINE_NR ]]; then
    echo -e "[ERROR] [$(date '+%D-%T')]" >> $CAFE_LOG_FILE
    echo "CURL ==> $CUSTOM_CURL" >> $CAFE_LOG_FILE
    cat $CAFE_FILE >> $CAFE_LOG_FILE
    rm $CAFE_FILE
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
    RESPONSE_LINE_NR=$(($CAFE_CODE_TIME_LINE_NR - 1))
    FORMATTED_RESPONSE_LINE_NR=$(($RESPONSE_LINE_NR - 1))
        
    # Delete lines 
    sed "${RESPONSE_LINE_NR},${CAFE_CODE_TIME_LINE_NR}d" $CAFE_FILE | sed '/CAFE_CODE_TIME/d' > $TMP_RES
        
    # Paste formatted response
    if [ $CAFE_SHOW_HEADERS = 'none' ]; then
        cat $TMP_RES_FILE > $CAFE_FILE
    else
        sed "${FORMATTED_RESPONSE_LINE_NR} r ${TMP_RES_FILE}" $TMP_RES > $CAFE_FILE
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
    # Delete CAFE_CODE_TIME
    sed "${CAFE_CODE_TIME_LINE_NR}d" $CAFE_FILE | sed '/CAFE_CODE_TIME/d' > $TMP_RES
    cat $TMP_RES > $CAFE_FILE
fi

# Delete random temporary file
rm $TMP_RES


