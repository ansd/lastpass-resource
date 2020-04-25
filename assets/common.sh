#!/usr/bin/env/bash

lpass_login() {
  local username
  local password
  username=$(jq -r .source.username <<< "$1")
  password=$(jq -r .source.password <<< "$1")

  echo "$password" | LPASS_DISABLE_PINENTRY=1 lpass login --trust --force "$username" >/dev/null
}
