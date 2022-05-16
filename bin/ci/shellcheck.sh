#!/bin/bash

set -euo pipefail

# Run shellcheck against any files that appear to be shell script based on
# filename or `file` output
# Exclude *.ps1 files because shellcheck doesn't support them
# Exclude hooks and config because the handlebars syntax confuses shellcheck
# Exclude the following shellcheck issues since they're pervasive and innocuous:
# https://github.com/koalaman/shellcheck/wiki/SC1008
# https://github.com/koalaman/shellcheck/wiki/SC1083
# https://github.com/koalaman/shellcheck/wiki/SC1090
# https://github.com/koalaman/shellcheck/wiki/SC1091
# https://github.com/koalaman/shellcheck/wiki/SC1117
# https://github.com/koalaman/shellcheck/wiki/SC2027
# https://github.com/koalaman/shellcheck/wiki/SC2034
# https://github.com/koalaman/shellcheck/wiki/SC2039
# https://github.com/koalaman/shellcheck/wiki/SC2140
# https://github.com/koalaman/shellcheck/wiki/SC2148
# https://github.com/koalaman/shellcheck/wiki/SC2153
# https://github.com/koalaman/shellcheck/wiki/SC2154
# https://github.com/koalaman/shellcheck/wiki/SC2164
# https://github.com/koalaman/shellcheck/wiki/SC2239

SHELLCHECK_IGNORE="SC1008,SC1083,SC1090,SC1091,SC1117,SC2027,SC2034,SC2039,SC2140,SC2148,SC2153,SC2154,SC2164,SC2239"

plan_path="$1"

echo "--- :bash: [$plan_path] Running shellcheck"

# Record what version of shellcheck we used in this CI run
shellcheck --version

find "$plan_path" -type f \
  -and \( -name "*.*sh" \
      -or -exec sh -c 'file -b "$1" | grep -q "shell script"' -- {} \; \) \
  -and \! -path "*.ps1" \
  -and \! -path "$plan_path/hooks/*" \
  -and \! -path "$plan_path/config/*" \
  -print0 \
  | xargs -0 shellcheck --external-sources --exclude="${SHELLCHECK_IGNORE}"

# shellcheck disable=SC2181
if [[ $? -eq 0 ]]; then
  echo "--- :shell: [$plan_path] Shellcheck run successful"
fi
