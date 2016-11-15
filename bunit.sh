#!/bin/bash

# Test bash scripts.
# This small utility can test bash unit tests. Unit tests must be located in 
# their own folder (called __tests__/ by default), and end with a *.test.sh
# extension.


# CLI logic.
# Execute getopt on the arguments passed to this program.
PARSED_OPTIONS=$(getopt -n "$0"  -o ht:v --long "help,tests:,verbose"  -- "$@")

# Bad arguments, something went wrong. Abort.
if [ $? -ne 0 ]; then
  exit 1
fi

# A little magic, necessary when using getopt.
eval set -- "$PARSED_OPTIONS"

# The default tests source folder.
SOURCE='tests';
# Are we in verbose mode? Defaults to "no".
VERBOSE=0
# Was the currently running test file described? If so, intermediate reports 
# are displayed.
DESCRIBED=0
# Assertions counter, global and intermediate.
ASSERTIONS=0
INTERM_ASSERTIONS=0
# Failed assertions counter, global and intermediate.
FAILED=0
INTERM_FAILED=0
# Output colors.
RESET='\e[0m'
RED='\e[1;31m'
GREEN='\e[0;32m'
BLUE='\e[0;34m'
# Variable to contain the report text.
REPORT=''
# Code with which to exit.
EXIT_CODE=0

function __print_help()
{
  echo "Help is on the way..."
}

# Fetch all test files, load them, and execute defined tests.
# Test functions must be prefixed with "test_", and use a standard Bash-style
# definition.
function __get_and_execute_tests()
{
    if [[ -d "$SOURCE" ]]; then
      LIST=$(ls $SOURCE/*.test.sh)
      for file in  $LIST; do
      	source $file
        for func in $(grep -ie '\(function\s\+test_\w\+\|test_\w\+\s*(\s*)\)' $file | sed 's/function\s\+//' | sed -e 's/\s*(\s*)\s*{\?\s*//'); do
          $func
        done
	if (( DESCRIBED > 0 )); then
	  __intermediate_report
	  INTERM_ASSERTIONS=0
	  INTERM_FAILED=0
	  DESCRIBED=0
	fi
      done
      __final_report
      echo -e $REPORT
      exit $EXIT_CODE
    else
      echo "No ${SOURCE}/ folder. Aborting."
      exit 1
    fi
}

# Print a final report, after all assertions have been run.
function __final_report()
{
    SUCCESS=$((ASSERTIONS-FAILED))
    __print "\nFinished. Ran ${ASSERTIONS} assertions in total."
    if (( SUCCESS > 0)); then
      __print "\t${GREEN}✓ ${SUCCESS} passed${RESET}"
    fi
    if (( FAILED > 0 )); then
      __print "\t${RED}✗ ${FAILED} failed${RESEt}"
      EXIT_CODE=1
    fi
}

# Print an intermediate report, after all assertions have been run for a single
# test file.
function __intermediate_report()
{
    SUCCESS=$((INTERM_ASSERTIONS-INTERM_FAILED))
    MSG="${BLUE}Ran ${INTERM_ASSERTIONS} assertions,${RESET}"
    AND=0
    if (( SUCCESS > 0)); then
      MSG+=" ${GREEN}${SUCCESS} passed${RESET}"
      AND=1
    fi
    if (( INTERM_FAILED > 0 )); then
      if (( AND > 0 )); then
        MSG+=" ${BLUE}and${RESET}"
      fi
      MSG+=" ${RED}${INTERM_FAILED} failed${RESEt}"
    fi
    __print $MSG
}

# Print a report for a single assertion. If not in verbose mode, successful
# assertions will not be printed.
function __report()
{
    ((ASSERTIONS++))
    ((INTERM_ASSERTIONS++))
    if [[ -z "$2" ]]; then
      if (( VERBOSE > 0 )); then
        __print "\t${GREEN}✓ Success:  ${1}${RESET}"
      fi
    else
        ((FAILED++))
        ((INTERM_FAILED++))
	__print "\t${RED}✗ Failed:   ${1}\n            ${2}${RESET}"
    fi
}

function __print()
{
    REPORT+="$1"
    REPORT+="\n"
}

# Describe the test suite.
# This should be called at the top of the test file. It is used to describe the
# tests being called. Only 1 describe should be used per *.test.sh file.
function describe()
{
    DESCRIBED=1
    echo -e "\n${BLUE}----- ${1} ------${RESET}"
}

function assert_equals()
{
    if [ "$1" = "$2" ]
    then
        __report "$3"
        return 0
    else
        __report "$3" "Args: $1, $2"
        return 1
    fi
}

function assert_not_equals()
{
    if [ "$1" != "$2" ]
    then
        __report "$3"
        return 0
    else
        __report "$3" "Args: $1, $2"
        return 1
    fi
}

function assert_exit_code()
{
    `$1 > /dev/null 2>&1`
    if [ "$?" = "$2" ]
    then
        __report "$3"
        return 0
    else
        __report "$3" "Command: $4"
        return 1
    fi
}

function assert_pass()
{
    __report "$1"
    return 0
}

function assert_fail()
{
    __report "assert_fail()" "$1"
    return 1
}

# Start the program.
while true;
do
  case "$1" in
    -h|--help)
      __print_help
      shift;;
    -v|--verbose)
      VERBOSE=1
      shift;;
    -t|--tests)
      if [ -n "$2" ];
      then
        SOURCE=$2
      fi  
      shift 2;; 
    --) 
      shift
      break;;
  esac
done

# Load and execute the test functions.
__get_and_execute_tests

