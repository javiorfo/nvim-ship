##!/usr/bin/env bash
# Author: Javier Orfo

while getopts "t:m:u:f:h:c:s:d:b:" ARG; do
  case $ARG in
    t)
      VURL_TIMEOUT=$OPTARG
      ;;
    m)
      VURL_METHOD=$OPTARG
      ;;
    u)
      VURL_URL=$OPTARG
      ;;
    f)
      VURL_FILE=$OPTARG
      ;;
    h)
      VURL_SHOW_HEADERS=$OPTARG
      ;;
    c)
      VURL_HEADERS=$OPTARG
      ;;
    s)
      VURL_SAVE=$OPTARG
      ;;
    d)
      VURL_OUTPUT_FOLDER=$OPTARG
      ;;
    b)
      VURL_BODY=$OPTARG
      ;;
  esac
done

if [ $VURL_SAVE = "true" ]; then
    # If output folder does not exist, then create it
    [[ -d $VURL_OUTPUT_FOLDER ]] || mkdir -p $VURL_OUTPUT_FOLDER
fi

# Check if body is included
[[ ${#VURL_BODY} -gt 0 ]] && VURL_BODY="-d '${VURL_BODY}'"

# Headers options
if [ $VURL_SHOW_HEADERS = 'res' ]; then
    SHOW_RES_HEAD="-i"
elif [ $VURL_SHOW_HEADERS = 'all' ]; then
    SHOW_RES_HEAD="-v"
    FILTER_SED="| sed '/^* /d; /bytes data]$/d; s/> //; s/< //'"
fi
# Remove Windows chars
FILTER_TR="| tr '\015' '\t'"

# Custom cUrl
CUSTOM_CURL="curl -s $SHOW_RES_HEAD --connect-timeout $VURL_TIMEOUT $VURL_HEADERS $VURL_BODY \
-w '\nVURL_CODE_TIME=%{http_code},%{time_total}\n%{onerror}ERROR %{errormsg}' \
-X $VURL_METHOD '$VURL_URL' 2>&1 $FILTER_SED $FILTER_TR > $VURL_FILE"

eval $CUSTOM_CURL

# Store status code and time
touch /tmp/vurl_tmp
grep 'VURL_CODE_TIME' $VURL_FILE | sed 's/VURL_CODE_TIME=//g' > /tmp/vurl_tmp

# Extract data response
RES_LINE=$(grep -v -e '^$' $VURL_FILE | grep -B1 'VURL_CODE_TIME' | grep -v 'VURL_CODE_TIME') 

# Extract VURL_CODE_TIME
VURL_CODE_TIME_LINE_NR=$(grep -v -e '^$' $VURL_FILE | grep -n 'VURL_CODE_TIME' | cut -f1 -d:)

# Create ramdom temporary file
TMP_RES=$(mktemp)

# Format response
formatted_response() {
    # Format response
    TMP_RES_FILE=$(mktemp)
    echo $RES_LINE | $@ > $TMP_RES_FILE
        
    # Extract line numbers to delete
    RESPONSE_LINE_NR=$(($VURL_CODE_TIME_LINE_NR - 1))
    FORMATTED_RESPONSE_LINE_NR=$(($RESPONSE_LINE_NR - 1))
        
    # Delete lines 
    sed "${RESPONSE_LINE_NR},${VURL_CODE_TIME_LINE_NR}d" $VURL_FILE | sed '/VURL_CODE_TIME/d' > $TMP_RES
        
    # Paste formatted response
    if [ $VURL_SHOW_HEADERS = 'none' ]; then
        cat $TMP_RES_FILE > $VURL_FILE
    else
        sed "${FORMATTED_RESPONSE_LINE_NR} r ${TMP_RES_FILE}" $TMP_RES > $VURL_FILE
    fi

    rm $TMP_RES_FILE
}

# Check if response is unformatted
if [ ${#RES_LINE} -gt 2 ] && ([[ $RES_LINE = \{* ]] || [[ $RES_LINE = \[* ]]); then
    # JSON
    formatted_response "jq"
elif [[ $RES_LINE = *"<?xml"* ]]; then
    # XML
    formatted_response "tidy -xml -quiet"
    elif[[ $RES_LINE = *"<html>"* ]]; then
        # HTML
        formatted_response "tidy -quiet"
else
    # Delete VURL_CODE_TIME
    sed "${VURL_CODE_TIME_LINE_NR}d" $VURL_FILE | sed '/VURL_CODE_TIME/d' > $TMP_RES
    cat $TMP_RES > $VURL_FILE
fi

# Delete random temporary file
rm $TMP_RES


