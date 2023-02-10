##!/usr/bin/env bash
# Author: Javier Orfo

while getopts "t:m:u:f:h:c:s:d:b:" ARG; do
  case $ARG in
    t)
      DIAMOND_TIMEOUT=$OPTARG
      ;;
    m)
      DIAMOND_METHOD=$OPTARG
      ;;
    u)
      DIAMOND_URL=$OPTARG
      ;;
    f)
      DIAMOND_FILE=$OPTARG
      ;;
    h)
      DIAMOND_SHOW_HEADERS=$OPTARG
      ;;
    c)
      DIAMOND_HEADERS=$OPTARG
      ;;
    s)
      DIAMOND_SAVE=$OPTARG
      ;;
    d)
      DIAMOND_OUTPUT_FOLDER=$OPTARG
      ;;
    b)
      DIAMOND_BODY=$OPTARG
      ;;
  esac
done

if [ $DIAMOND_SAVE = "true" ]; then
    # If output folder does not exist, then create it
    [[ -d $DIAMOND_OUTPUT_FOLDER ]] || mkdir -p $DIAMOND_OUTPUT_FOLDER
fi

# Check if body is included
[[ ${#DIAMOND_BODY} -gt 0 ]] && DIAMOND_BODY="-d '${DIAMOND_BODY}'"

# Headers options
if [ $DIAMOND_SHOW_HEADERS = 'res' ]; then
    SHOW_RES_HEAD="-i"
elif [ $DIAMOND_SHOW_HEADERS = 'all' ]; then
    SHOW_RES_HEAD="-v"
    FILTER_SED="| sed '/^* /d; /bytes data]$/d; s/> //; s/< //'"
fi
# Remove Windows chars
FILTER_TR="| tr '\015' '\t'"

# Custom cUrl
CUSTOM_CURL="curl -s $SHOW_RES_HEAD --connect-timeout $DIAMOND_TIMEOUT $DIAMOND_HEADERS $DIAMOND_BODY \
-w '\nDIAMOND_CODE_TIME=%{http_code},%{time_total}\n%{onerror}ERROR %{errormsg}' \
-X $DIAMOND_METHOD '$DIAMOND_URL' 2>&1 $FILTER_SED $FILTER_TR > $DIAMOND_FILE"

eval $CUSTOM_CURL

# Store status code and time
touch /tmp/diamond_tmp
grep 'DIAMOND_CODE_TIME' $DIAMOND_FILE | sed 's/DIAMOND_CODE_TIME=//g' > /tmp/diamond_tmp

# Extract data response
RES_LINE=$(grep -v -e '^$' $DIAMOND_FILE | grep -B1 'DIAMOND_CODE_TIME' | grep -v 'DIAMOND_CODE_TIME') 

# Extract DIAMOND_CODE_TIME
DIAMOND_CODE_TIME_LINE_NR=$(grep -v -e '^$' $DIAMOND_FILE | grep -n 'DIAMOND_CODE_TIME' | cut -f1 -d:)

# Create ramdom temporary file
TMP_RES=$(mktemp)

# Format response
format_response() {
    # Format response
    TMP_RES_FILE=$(mktemp)
    echo $RES_LINE | $@ > $TMP_RES_FILE
        
    # Extract line numbers to delete
    RESPONSE_LINE_NR=$(($DIAMOND_CODE_TIME_LINE_NR - 1))
    FORMATTED_RESPONSE_LINE_NR=$(($RESPONSE_LINE_NR - 1))
        
    # Delete lines 
    sed "${RESPONSE_LINE_NR},${DIAMOND_CODE_TIME_LINE_NR}d" $DIAMOND_FILE | sed '/DIAMOND_CODE_TIME/d' > $TMP_RES
        
    # Paste formatted response
    if [ $DIAMOND_SHOW_HEADERS = 'none' ]; then
        cat $TMP_RES_FILE > $DIAMOND_FILE
    else
        sed "${FORMATTED_RESPONSE_LINE_NR} r ${TMP_RES_FILE}" $TMP_RES > $DIAMOND_FILE
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
    # Delete DIAMOND_CODE_TIME
    sed "${DIAMOND_CODE_TIME_LINE_NR}d" $DIAMOND_FILE | sed '/DIAMOND_CODE_TIME/d' > $TMP_RES
    cat $TMP_RES > $DIAMOND_FILE
fi

# Delete random temporary file
rm $TMP_RES


