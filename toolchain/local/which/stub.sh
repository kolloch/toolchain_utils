#! /bin/sh

cat <<EOF >&2
Usage: ${0} ${@}

This is a stub executable that is provided when the \`${0##*/}\` binary is not found on \${PATH}:

    ${PATH}

It will always exit with a failure code. Either:

- Install the required binary locally
- Setup a hermetic toolchain for the binary
EOF

exit 126
