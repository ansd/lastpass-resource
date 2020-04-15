#!/usr/bin/env bats

@test "when given version exists, it is placed in given directory outputting given version and metadata" {
  lpass() {
    if [[ "$1" == "show" ]];then
      cat data/account.json
    fi
  }
  export -f lpass

  tmp_dir=$(mktemp -d -t lastpass-resource-XXX)

  run ../in $tmp_dir < data/stdin.json

  [ "$status" -eq 0 ]

  id=$(jq -r .id < $tmp_dir/item)
  last_modified_gmt=$(jq -r .last_modified_gmt < $tmp_dir/item)
  name=$(jq -r .name < $tmp_dir/item)
  [ "$id" = '1000000000000000033' ]
  [ "$last_modified_gmt" = '0000000011' ]
  [ "$name" = 'name3' ]
  rm -rf $tmp_dir

  version=$(jq -r .version.last_modified_gmt_id <<< "$output")
  [ "$version" = '0000000011_1000000000000000033' ]

  metadata=$(jq -r .metadata.[0] <<< "$output")
  [ $(jq -r '.name' <<< "$metadata") = 'ID' ]
  [ $(jq -r '.value' <<< "$metadata") = '1000000000000000033' ]
}

@test "when given version's id does not exist, it errors" {
  lpass() {
    if [[ "$1" == "show" ]];then
      echo "Error: Could not find specified account(s)." >&2
      exit 2
    fi
  }
  export -f lpass

  run ../in fakeDir < data/stdin.json

  [ "$status" -eq 2 ]
  [ "$output" = "Error: Could not find specified account(s)." ]
}

@test "when given version's last_modified_gmt does not match item's last_modified_gmt, it errors" {
  lpass() {
    if [[ "$1" == "show" ]];then
      cat data/account-updated.json
    fi
  }
  export -f lpass

  run ../in fakeDir < data/stdin.json

  [ "$status" -eq 1 ]
  [ "$output" = "Account with id=1000000000000000033 has last_modified_gmt=0000000012 (requested last_modified_gmt=0000000011 is outdated)" ]
}
