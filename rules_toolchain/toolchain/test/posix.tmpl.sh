#! /bin/sh

# e: quit on command errors
# u: quit on undefined variables
set -eu

# Bazel substitutions
EXECUTABLE="{{executable}}"
STDOUT="{{stdout}}"
STDERR="{{stderr}}"
readonly EXECUTABLE STDOUT STDERR

# Test environment
JUNIT="${XML_OUTPUT_FILE-junit.xml}"
readonly JUNIT

# Run the toolchain executable and validate the output
"${EXECUTABLE}" "${@}" >stdout.txt 2>stderr.txt

non_empty() (
  FILEPATH="${1}"
  readonly FILEPATH
  if ! test -s "${FILEPATH}"; then
    printf '  <testcase name="%s">\n' "${FILEPATH}"
    printf '    <failure type="EmptyFile">%s contained no content</failure>\n' "${FILEPATH}"
    printf '  </testcase>\n'
  else
    printf '  <testcase name="%s"/>\n' "${FILEPATH}"
  fi
)

empty() (
  FILEPATH="${1}"
  if test -s "${FILEPATH}"; then
    printf '  <testcase name="%s">\n' "${FILEPATH}"
    printf '    <failure type="NonEmptyFile">%s contained unexpected content:\n' "${FILEPATH}"
    while IFS= read -r LINE; do
      printf '%s\n' "${LINE}"
    done
    printf '%s</failure>\n' "${LINE}"
    printf '  </testcase>\n'
  else
    printf '  <testcase name="%s"/>\n' "${FILEPATH}"
  fi
)

diff() (
  FILEPATH="${1}"
  EXPECTED="${2}"
  while true; do
    FAILS=0
    IFS= read -r A <&3 || FAILS=$((FAILS + 1))
    IFS= read -r B <&4 || FAILS=$((FAILS + 1))
    if test "${FAILS}" -eq 1; then
      printf '  <testcase name="%s">\n' "${FILEPATH}"
      printf '    <failure type="Difference">%s contained different line counts:\n' "${FILEPATH}"
      printf '%s %s\n' '---' "${FILEPATH}"
      printf '%s %s\n' '+++' "${EXPECTED}"
      printf '@@ -1 +1 @@\n'
      printf '%s%s\n' '-' "${A-}"
      printf '%s%s\n' '+' "${B-}"
      printf '</failure>\n'
      printf '  </testcase>\n'
      exit
    elif test "${FAILS}" -eq 2; then
      exit
    elif test "${A}" != "${B}"; then
      printf '  <testcase name="%s">\n' "${FILEPATH}"
      printf '    <failure type="Difference">%s contained different content:\n' "${FILEPATH}"
      printf '%s %s\n' '---' "${FILEPATH}"
      printf '%s %s\n' '+++' "${EXPECTED}"
      printf '@@ -1 +1 @@\n'
      printf '%s%s\n' '-' "${A}"
      printf '%s%s\n' '+' "${B}"
      printf '</failure>\n'
      printf '  </testcase>\n'
      exit
    fi
  done 3<"${FILEPATH}" 4<"${EXPECTED}"

  printf '  <testcase name="%s"/>\n' "${FILEPATH}"
)

validate() (
  FILEPATH="${1}"
  EXPECTED="${2}"

  if ! test -f "${FILEPATH}"; then
    printf '  <testcase name="%s">\n' "${FILEPATH}"
    printf '    <failure type="NotFoundFile">%s was not found</failure>\n' "${FILEPATH}"
    printf '  </testcase>\n'
    exit
  elif ! test -f "${EXPECTED}"; then
    printf '  <testcase name="%s">\n' "${FILEPATH}"
    printf '    <failure type="NotFoundFile">%s was not found</failure>\n' "${EXPECTED}"
    printf '  </testcase>\n'
    exit
  fi

  case "${EXPECTED}" in
  *"/toolchain/test/non-empty")
    non_empty "${FILEPATH}" "${JUNIT}"
    ;;
  *"/toolchain/test/empty")
    empty "${FILEPATH}" "${JUNIT}"
    ;;
  *)
    diff "${FILEPATH}" "${EXPECTED}" "${JUNIT}"
    ;;
  esac
)

junit() (
  COUNT="${#}"
  printf '<testsuite tests="%s">\n' $((COUNT / 2))
  while ! test -z ${2+x}; do
    FILEPATH="${1}"
    EXPECTED="${2}"
    shift 2
    validate "${FILEPATH}" "${EXPECTED}"
  done
  printf '</testsuite>\n'
)

junit \
  stdout.txt "${STDOUT}" \
  stderr.txt "${STDERR}" \
  >"${JUNIT}"

while IFS= read -r LINE; do
  if test -z "${LINE#*</failure>*}"; then
    exit 1
  fi
done <"${JUNIT}"
