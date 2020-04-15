#!/usr/bin/env bats

lpass() {
  if [[ "$1" == "ls" ]]; then
    echo "fake account IDs"
  fi
}
export -f lpass

@test "when given version is latest and valid, it prints that version" {
  bash() {
    if [[ "$1" == "-c" ]];then
      cat data/accounts.json
    fi
  }
  export -f bash

  run ../check < data/stdin.json

  [ "$status" -eq 0 ]

  length=$(jq length <<< "$output")
  [ "$length" -eq 1 ]
  version=$(jq -r .[0].last_modified_gmt_id <<< "$output")
  [ "$version" = '0000000011_1000000000000000033' ]
}

@test "when given version is outdated and valid, it prints given and new versions in chronological order" {
  bash() {
    if [[ "$1" == "-c" ]];then
      cat data/accounts-updated.json
    fi
  }
  export -f bash

  run ../check < data/stdin.json

  [ "$status" -eq 0 ]

  length=$(jq length <<< "$output")
  [ "$length" -eq 3 ]
  v0=$(jq -r .[0].last_modified_gmt_id <<< "$output")
  v1=$(jq -r .[1].last_modified_gmt_id <<< "$output")
  v2=$(jq -r .[2].last_modified_gmt_id <<< "$output")
  [ "$v0" = '0000000011_1000000000000000033' ]
  [ "$v1" = '0000000012_1000000000000000022' ]
  [ "$v2" = '0000000013_1000000000000000044' ]
}

@test "when given version is invalid, it prints new versions in chronological order" {
  bash() {
    if [[ "$1" == "-c" ]];then
      cat data/accounts-given-invalid.json
    fi
  }
  export -f bash

  run ../check < data/stdin.json

  [ "$status" -eq 0 ]

  length=$(jq length <<< "$output")
  [ "$length" -eq 2 ]
  v0=$(jq -r .[0].last_modified_gmt_id <<< "$output")
  v1=$(jq -r .[1].last_modified_gmt_id <<< "$output")
  [ "$v0" = '0000000012_1000000000000000033' ]
  [ "$v1" = '0000000013_1000000000000000044' ]
}

@test "when no version is given (in first request), it prints the current version" {
  bash() {
    if [[ "$1" == "-c" ]];then
      cat data/accounts.json
    fi
  }
  export -f bash

  run ../check < data/stdin-no-version.json

  [ "$status" -eq 0 ]

  length=$(jq length <<< "$output")
  [ "$length" -eq 1 ]
  v0=$(jq -r .[0].last_modified_gmt_id <<< "$output")
  [ "$v0" = '0000000011_1000000000000000033' ]
}

@test "when no items are stored in LastPass, it prints an empty list of versions" {
  lpass() {
    if [[ "$1" == "ls" ]]; then
      :
    fi
  }

  run ../check < data/stdin.json

  [ "$status" -eq 0 ]
  [ "$output" = '[]' ]
}

@test "when no items are stored in LastPass and no version is given, it prints an empty list of versions" {
  lpass() {
    if [[ "$1" == "ls" ]]; then
      :
    fi
  }

  run ../check < data/stdin-no-version.json

  [ "$status" -eq 0 ]
  [ "$output" = '[]' ]
}
