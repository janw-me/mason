#!/usr/bin/env bash

function set_passwords() {
  echo 'Setting passwords to 123'
  ${WP_CLI_Localy_Quick} db query "UPDATE $(${WP_CLI_Localy_Quick} db prefix)users SET user_pass = MD5('123');"
}
