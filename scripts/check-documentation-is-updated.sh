#!/bin/bash
# From http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

make documentation-ci >/dev/null 2>&1

exit $(git status --porcelain doc | wc -l | tr -d " ")
