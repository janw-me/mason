#!/usr/bin/env bash

function db_import() {
  echo 'Dumping DB'
  PREFIX=$(wp @live config get table_prefix --type=variable)
  wp @live db dump --exclude_tables=${PREFIX}toolset_maps_address_cache - > dump.sql
  #------------------------------------------------------------------------^ Formatting will strip this space, keep it!!
  echo 'Importing DB'
  wp db reset --yes
  sed -i "1{/999999.*sandbox/d}" dump.sql
  wp db import dump.sql
  # cleanup
  rm dump.sql
}
