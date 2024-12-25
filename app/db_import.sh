#!/usr/bin/env bash

function db_import() {
  echo 'Dumping DB'
  PREFIX=$(${WP_CLI_Remote_Quick} config get table_prefix --type=variable)
  ${WP_CLI_Remote_Fully} db dump --exclude_tables=${PREFIX}toolset_maps_address_cache - > dump.sql
  #--------------------------------------------------------------------------------------^ Formatting will strip this space, keep it!!
  echo 'Importing DB'

  # Strip sandbox mode it's at the top of the dump.
  sed '1{/\/\*M!999999\\- enable the sandbox mode \*\//d}' dump.sql > dump-stripped.sql
  if [[ -f dump-stripped.sql ]]; then
    mv dump-stripped.sql dump.sql
  fi
  ${WP_CLI_Localy_Fully} db reset --yes
  ${WP_CLI_Localy_Fully} db import dump.sql
  # cleanup
  rm dump.sql
}
