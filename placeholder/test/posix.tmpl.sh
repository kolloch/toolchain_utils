#! /bin/sh

# Strict shell
set -o errexit -o nounset

# Bazel substitutions
CODE="{{code}}"
readonly CODE

# Simple!
exit "${CODE}"
