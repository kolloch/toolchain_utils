#!/bin/sh

# e: quit on command errors
# u: quit on undefined variables
set -eu

# Bazel substitutions
EXECUTABLE="{{path}}"
readonly EXECUTABLE

# Validate the executable is...executable
if ! test -f "${EXECUTABLE}"; then
  echo >&2 "Not found: ${EXECUTABLE}"
  exit 69
elif ! test -x "${EXECUTABLE}"; then
  echo >&2 "Not executable: ${EXECUTABLE}"
  exit 123
fi

# Pass on the argument to the actual executable
"${EXECUTABLE}" "${@}"
