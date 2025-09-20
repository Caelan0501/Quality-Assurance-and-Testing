#!/usr/bin/env bash
# Generated with ChatGPT
# check_password.sh
# Validate a password against a configurable policy.
# Exit codes:
#   0 = valid
#   1 = invalid (generic)
#   2 = missing password
#   3 = blacklisted (found in provided common-password file)

set -u

# Defaults (change as you like)
MIN_LEN=8
MAX_LEN=64
REQUIRE_UPPER=1
REQUIRE_LOWER=1
REQUIRE_DIGIT=1
REQUIRE_SPECIAL=1   # requires at least one non-alphanumeric char
NO_SPACES=1

COMMON_PW_FILE=""

usage() {
  cat <<USAGE
Usage: $0 [-p password] [-f common_pw_file] [-m min_len] [-M max_len]
  -p PASSWORD         Provide password on command line (less secure).
  -f FILE             Path to common-password file (one password per line).
  -m MIN_LEN          Minimum length (default $MIN_LEN).
  -M MAX_LEN          Maximum length (default $MAX_LEN).
  --no-special        Do not require special character.
  --no-upper          Do not require an uppercase letter.
  --no-lower          Do not require a lowercase letter.
  --no-digit          Do not require a digit.
  --allow-spaces      Allow spaces in password.
  -h                  Show this help.
Examples:
  $0 -p 'My$'ecret123'
  read -s PW; echo; $0 -p \"\$PW\"
USAGE
  exit 1
}

# parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    -p) PASSWORD="$2"; shift 2 ;;
    -f) COMMON_PW_FILE="$2"; shift 2 ;;
    -m) MIN_LEN="$2"; shift 2 ;;
    -M) MAX_LEN="$2"; shift 2 ;;
    --no-special) REQUIRE_SPECIAL=0; shift ;;
    --no-upper) REQUIRE_UPPER=0; shift ;;
    --no-lower) REQUIRE_LOWER=0; shift ;;
    --no-digit) REQUIRE_DIGIT=0; shift ;;
    --allow-spaces) NO_SPACES=0; shift ;;
    -h|--help) usage ;;
    *) echo "Unknown option: $1"; usage ;;
  esac
done

# If password not provided, prompt for it securely
if [[ -z "${PASSWORD:-}" ]]; then
  if [[ -t 0 ]]; then
    # interactive terminal
    read -s -p "Password: " PASSWORD
    echo
  else
    echo "Error: no password provided and not interactive." >&2
    exit 2
  fi
fi

# Quick null check
if [[ -z "$PASSWORD" ]]; then
  echo "Invalid: empty password." >&2
  exit 2
fi

pw="$PASSWORD"
len=${#pw}

fail=0
reasons=()

# length checks
if (( len < MIN_LEN )); then
  reasons+=("too short (length $len < $MIN_LEN)")
  fail=1
fi
if (( len > MAX_LEN )); then
  reasons+=("too long (length $len > $MAX_LEN)")
  fail=1
fi

# spaces
if [[ $NO_SPACES -eq 1 && "$pw" =~ [[:space:]] ]]; then
  reasons+=("contains whitespace (spaces/tabs not allowed)")
  fail=1
fi

# character class checks using bash regex
if [[ $REQUIRE_UPPER -eq 1 && ! "$pw" =~ [A-Z] ]]; then
  reasons+=("missing uppercase letter")
  fail=1
fi
if [[ $REQUIRE_LOWER -eq 1 && ! "$pw" =~ [a-z] ]]; then
  reasons+=("missing lowercase letter")
  fail=1
fi
if [[ $REQUIRE_DIGIT -eq 1 && ! "$pw" =~ [0-9] ]]; then
  reasons+=("missing digit")
  fail=1
fi
if [[ $REQUIRE_SPECIAL -eq 1 && "$pw" =~ ^[[:alnum:]]+$ ]]; then
  # ^[[:alnum:]]+$ means all characters are alnum so no special present
  reasons+=("missing special character (non-alphanumeric)")
  fail=1
fi

# simple repetition check: same character 5+ times
if printf '%s\n' "$pw" | grep -qE '([[:print:]])\1\1\1\1'; then
  reasons+=("contains a 5+ repeated-character run (weak)")
  fail=1
fi

# simple sequence check (detect ascending sequences of length 4 like 1234 or abcd)
detect_sequence() {
  s=$(echo "$1" | sed 's/./&\n/g' | awk '1' | tr -d '\n')
  # fallback simple approach: check for common numeric sequences and alphabetic
  if echo "$1" | grep -qiE '(0123|1234|2345|3456|4567|5678|6789|abcd|bcde|cdef|defg|efgh|fghi|ghij|hijk|ijkl|jklm|klmn|lmno|mnop|nopq|opqr|pqrs|qrst|rstu|stuv|tuvw|uvwx|vwxy|wxyz)'; then
    return 0
  fi
  return 1
}
if detect_sequence "$pw"; then
  reasons+=("contains an easy sequential substring (e.g. 1234 or abcd)")
  fail=1
fi

# check against common password file if provided
if [[ -n "$COMMON_PW_FILE" && -f "$COMMON_PW_FILE" ]]; then
  # case-insensitive exact match search
  if grep -Fxi -q -- "$pw" "$COMMON_PW_FILE"; then
    echo "Invalid: password is present in common-password blacklist ($COMMON_PW_FILE)." >&2
    exit 3
  fi
fi

# final decision
if [[ $fail -eq 0 ]]; then
  echo "PASS: password meets policy (length $len)."
  exit 0
else
  echo "FAIL: password does not meet policy for the following reasons:" >&2
  for r in "${reasons[@]}"; do
    echo "  - $r" >&2
  done
  exit 1
fi
