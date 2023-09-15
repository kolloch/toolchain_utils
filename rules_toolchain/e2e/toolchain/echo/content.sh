#!/bin/sh

# e: quit on command errors
# u: quit on undefined variables
set -eu

# Test setup
TEST_SCRIPT="${TEST_BINARY?TEST_BINARY is unset}"
TEST_FOLDER="${TEST_SCRIPT%/*}"
TEST_DATA="${TEST_FOLDER}/${1}"
TEST_EXPECTED="${2}"
readonly TEST_FOLDER TEST_DATA TEST_EXPECTED

# Validate the test data
if ! test -f "${TEST_DATA}"; then
  echo >&2 "Missing test DATA: ${TEST_DATA}"
  exit 2
elif ! test -r "${TEST_DATA}"; then
  echo >&2 "Unreadable test DATA: ${TEST_DATA}"
  exit 2
fi

# Validate the test content
while IFS= read -r LINE; do
  if test "${LINE}" != "${TEST_EXPECTED}"; then
    echo >&2 "Invalid data content:"
    echo >&2 " - actual  : ${LINE}"
    echo >&2 " - expected: ${TEST_EXPECTED}"
    exit 1
  fi
done <"${TEST_DATA}"
