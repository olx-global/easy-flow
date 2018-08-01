######################################################
# to_in_progress transitions a ticket to "IN PROGRESS"
# $1 : ticket id
#####################################################
function to_in_progress {
     TICKET=$1
     ##in our case 111 is the id of "in progress"
     [ -z "$JIRA_IN_PROGRESS_ID" ] && export JIRA_IN_PROGRESS_ID=111
     CURLDATA='{"transition":{"id":'"$JIRA_IN_PROGRESS_ID"'}}'
     RESPONSE=`curl --request POST \
	  --user "$JIRA_USER":"$JIRA_KEY"\
	  --header 'Accept: application/json' \
	  --header 'Content-Type: application/json' \
	  --data "$CURLDATA"\
	  --url 'https://'"$JIRA_SERVER"'/rest/api/2/issue/'"$TICKET"'/transitions'`
}

 #######################################################
# easy_branch creates a ticket and a branch (by default) #  
 #######################################################
function easy_branch {

	if [ -z "$JIRA_USER" ]; then
		echo "ERROR: Please set JIRA_USER env variable with your username for jira (usually an email)"
		return
	fi
	if [ -z "$JIRA_KEY" ]; then
		echo "ERROR: Please set JIRA_KEY env variable. You can get the key here: https://id.atlassian.com/manage/api-tokens" 
		return
	fi
	if [ -z "$JIRA_SERVER" ]; then
		echo "ERROR: Please set JIRA_SERVER env variable. Usually org.atlassian.com" 
		return
	fi
	if [ -z "$JIRA_BRANCH_SEPARATOR" ]; then
		JIRA_BRANCH_SEPARATOR="_"
	fi
	POSITIONAL=()
	TYPE="Task"
	SUMMARY=""
	DESCRIPTION=""
	LABELS=()
	TEAMS=()
	SQUAD=()
	DO_BRANCH=true

	shift $((OPTIND-1))
	while [[ $# -gt 0 ]]
	do
	key="$1"

	case $key in
	    -t|--type)
	    TYPE="$2"
	    shift # pass argument
	    shift
	    ;;
	    -d|--description)
	    DESCRIPTION="$2"
	    shift 
	    ;;
	    -l|--label)
	    LABELS+=("$2")
	    shift 
	    shift
	    ;;
	    -nb|--nobranch)
	    DO_BRANCH=false
	    shift 
	    ;;
	    *)    # unknown option
	    if [ -z "$SUMMARY" ]; then
	      SUMMARY=("$1") # save it in an array for later
	    else
	      SUMMARY=("$SUMMARY $1")
	    fi
	    shift 
	    ;;
	esac
	done
	if [ -z "$LABELS" ]; then
	    LABELS_JSON="[]"
	else
	    LABELS_JSON=$(printf '%s\n' "${LABELS[@]}" | jq -R . | jq -sc .)
	fi
	set -- "${POSITIONAL[@]}" # restore positional parameters
	CURLDATA='{
		    "fields": {
		       "project":
		       {
			  "key": "PAN"
		       },
		       "summary": "'$SUMMARY'",
		       "description": "'$DESCRIPTION'",
		       "issuetype": {
			  "name": "'$TYPE'"
		       },
		       "labels" : '$LABELS_JSON'
		   }
		}
	    '
	#echo $CURLDATA
	RESPONSE=`curl --request POST \
	  --user "$JIRA_USER":"$JIRA_KEY"\
	  --header 'Accept: application/json' \
	  --header 'Content-Type: application/json' \
	  --data "$CURLDATA"\
	  --url 'https://'"$JIRA_SERVER"'/rest/api/2/issue/'`
	ISSUE_KEY=$(echo "$RESPONSE" | jq -cr .key)
	if [[ "$ISSUE_KEY" == "null" ]]; then
		echo "ERROR: $RESPONSE"
	        return	
	fi
	if [ "$DO_BRANCH" = true ]; then
		SUMMARY_BRANCH=${SUMMARY// /_}
		BRANCH="$ISSUE_KEY$JIRA_BRANCH_SEPARATOR$SUMMARY_BRANCH"
		git branch $BRANCH
		git checkout $BRANCH
		to_in_progress $ISSUE_KEY
	else
	        echo "CREATED TICKET: $ISSUE_KEY"
	fi
}

