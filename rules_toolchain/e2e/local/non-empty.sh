#!/bin/sh

# e: quit on command errors
# u: quit on undefined variables
set -eu

# Test setup
TEST_SCRIPT="${TEST_BINARY?TEST_BINARY is unset}"
TEST_FOLDER="${TEST_SCRIPT%/*}"
TEST_DATA="${TEST_FOLDER}/${1}"
readonly TEST_FOLDER TEST_DATA

# Validate the test data
if ! test -f "${TEST_DATA}"; then
  echo >&2 "Missing test DATA: ${TEST_DATA}"
  tree
  exit 2
elif ! test -r "${TEST_DATA}"; then
  echo >&2 "Unreadable test DATA: ${TEST_DATA}"
  exit 2
fi

# Check no extra lines
while IFS="-" read -r CPU ARCH LIBC; do
  echo >&2 "Unexpected line: ${CPU}-${ARCH}-${LIBC}"
  exit 1
done <"${TEST_DATA}"

if test -z "${CPU}"; then
  echo >&2 "Empty CPU"
  exit 1
fi
if test -z "${ARCH}"; then
  echo >&2 "Empty ARCH"
  exit 1
fi
if test -z "${LIBC}"; then
  echo >&2 "Empty LIBC"
  exit 1
fi
