#!/bin/bash

# parse args
#while [[ $# -gt 0 ]]; do
#  case "$1" in
#    --csv) PASSWORD="$2"; shift 2 ;;
#    -f) COMMON_PW_FILE="$2"; shift 2 ;;
#    -m) MIN_LEN="$2"; shift 2 ;;
#    -M) MAX_LEN="$2"; shift 2 ;;
#    --no-special) REQUIRE_SPECIAL=0; shift ;;
#    --no-upper) REQUIRE_UPPER=0; shift ;;
#    --no-lower) REQUIRE_LOWER=0; shift ;;
#    --no-digit) REQUIRE_DIGIT=0; shift ;;
#    --allow-spaces) NO_SPACES=0; shift ;;
#    -h|--help) usage ;;
#    *) echo "Unknown option: $1"; usage ;;
#  esac
#done

#Requires Arguments
if [ "$#" -eq 0 ]; then
  echo "Error: No arguments provided. Usage: $0 <arg1> <arg2>"
  exit 1
fi

#Print all Arguments
for arg in "$@"; do
  echo "Arg: $arg"
done

# Get the absolute path of the script’s directory and check if it exists
script_dir="$(dirname "$(realpath "$0")")"
echo "Script directory: $script_dir"
file="$script_dir/$1"
if [[ -f "$file" ]]; then
  echo "$file exists!"
else
  echo "$file not found."
fi

cat $file
#Give program To Test
#Argument 1 - Program to Test - We will start with testing other shell scripts then extend to others


#./$1

## What Kind of Program is it
## How do we run it

#Gather Details for input
## What inputs are required
#Arguments n + 2 

#Gather Details for output
## What is the Expected Outputs for diffrent Combinations
#Argument n + 1

#Generate Test Cases
## How are they made

#Store Test Cases in another File
#Generate the new file
#echo "Test" > test.sh