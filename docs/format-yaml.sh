#!/usr/bin/env bash

# file=$1

# get line number from grep ouput
line_number() {
  cut -d ":" -f 1
}

# get list of line numbers where yaml code blocks start
# start_lines() {
#   grep -E '^```ya?ml' "$1" -n | line_number
# }

find_next_block_start() {
  local start=$1 file=$2

  find_next_pattern "$start" "$file" '^```ya?ml[:space:]*$'
}

find_next_block_end() {
  local start=$1 file=$2

  find_next_pattern "$start" "$file" '^```[:space:]*$'
}

find_next_pattern() {
  local start=$1 file=$2 pattern=$3 relative

  relative=$(sed -n "$start,\$p" "$file" | grep -E "$pattern" -m 1 -n | line_number)
  echo "$((start + relative - 1))"
}

print_between() {
  local start=$1 end=$2 file=$3
  sed -n "${start},${end}p" "$file"
}

print_between_non_inclusive() {
  local start=$1 end=$2 file=$3
  start=$((start + 1))
  end=$((end - 1))

  print_between "$start" "$end" "$file"
}

format() {
  prettier --parser yaml
}

update_block() {
  local start=$1 file=$2 blockstart blockend

  blockstart=$(find_next_block_start "$start" "$file")
  blockend=$(find_next_block_end "$start" "$file")

  print_between_non_inclusive "$blockstart" "$blockend" "$file" | format > formatted

  sed -i.bak "$((blockstart + 1)),$((blockend - 1))d" "$file"
  sed -i.bak "${blockstart}r formatted" "$file"
  rm "$file".bak
  rm formatted
}


