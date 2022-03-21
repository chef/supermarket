#!/usr/bin/env bash

set -euo pipefail
plan_path=$1

hab_usage=()
sleep_usage=()
exit_code=0

# Until the following PRs land, we cannot sleep in a lifecycle hook
# with the exception of 'run'
# habitat-sh/habitat#5954
# habitat-sh/habitat#5955
# habitat-sh/habitat#5956
# habitat-sh/habitat#5957
# habitat-sh/habitat#5958
# habitat-sh/habitat#5959
check_for_sleep() {
  local file

  file="$1"
  # Match lines containing `sleep N`, ignoring comments
  match="^([^#])*sleep [0-9]+"

  if grep -qE "$match" "$file"; then
    sleep_usage+=("$file")
    exit_code=1
  fi
}

check_for_hab() {
  local file

  file="$1"
  # Match anything that looks like we're attempting to call the hab cli
  # ignoring comments
  match="^([^#])*(\(\s*|\s+)hab\s"
  if grep -E -q "$match" "$file"; then
    hab_usage+=("$file")
    exit_code=1
  fi
}

echo "--- :thinking_face: [$plan_path] Checking for bad patterns"
readarray -t files < <(find "$plan_path" -type f)

for file in "${files[@]}"; do
  case $file in
    */plan.sh | */plan.ps1 )
      check_for_sleep "$file"
      ;;
    *hooks/run )
      check_for_hab "$file"
      ;;
    *hooks/*)
      check_for_hab "$file"
      check_for_sleep "$file"
      ;;
    **)
      echo "Skipping $file"
      ;;
  esac
done

if [[ "${#hab_usage[@]}" -ne 0 ]]; then
  echo "--- :habicat: The following files appear to be calling 'hab'"
  printf "%s\n" "${hab_usage[@]}"
fi

if [[ "${#sleep_usage[@]}" -ne 0 ]]; then
  echo "--- :sleep: The following files appear to be calling 'sleep'"
  printf "%s\n" "${sleep_usage[@]}"
fi

if [[ "$exit_code" -eq 0 ]]; then
  echo "--- :smiling_face: [$plan_path] No bad patterns found!"
fi
exit "$exit_code"
