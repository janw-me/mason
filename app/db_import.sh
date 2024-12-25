#!/usr/bin/env bash

function db_import() {
  echo 'Dumping DB'
  PREFIX=$(wp @live config get table_prefix --type=variable)
  wp @live db dump --exclude_tables=${PREFIX}toolset_maps_address_cache - > dump.sql
  #------------------------------------------------------------------------^ Formatting will strip this space, keep it!!
  echo 'Importing DB'

  # Strip sandbox mode it's at the top of the dump.
  sed '1{/\/\*M!999999\\- enable the sandbox mode \*\//d}' dump.sql > dump-stripped.sql
  if [[ -f dump-stripped.sql ]]; then
    mv dump-stripped.sql dump.sql
  fi
  wp db reset --yes
  wp db import dump.sql
  # cleanup
  rm dump.sql
}
