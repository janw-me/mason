#!/usr/bin/env bash

function db_import() {
  echo 'Dumping DB'

  if [[ -z "${TARGET_TABLES}" ]]; then
    TABLES=''
  else
    TABLES="--tables=${TARGET_TABLES}"
  fi

  ${WP_CLI_Remote_Fully} db dump ${TABLES} - > dump.sql
  #---------------------------------------^^^ Formatting will strip this space, keep it!!
  echo 'Importing DB'

  # Strip sandbox mode it's at the top of the dump.
  sed '1{/\/\*M!999999\\- enable the sandbox mode \*\//d}' dump.sql > dump-stripped.sql
  if [[ -f dump-stripped.sql ]]; then
    mv dump-stripped.sql dump.sql
  fi

  # Make sure all new data is imported.
  if [[ -z "${TARGET_TABLES}" ]]; then
    ${WP_CLI_Localy_Quick} db reset --yes
  else
    # Drop all tables that are to be imported.
    ${WP_CLI_Localy_Quick} db query "DROP TABLE IF EXISTS ${TARGET_TABLES};" --silent
  fi

  ${WP_CLI_Localy_Fully} db import dump.sql
  # cleanup
  rm dump.sql
}

function db_import_tables() {
  if [[ -z "$SUB_SITE" ]]; then
    TARGET_TABLES=''
    TARGET_TABLES_SHORT=''
  fi

  # get all tables with the prefix.
  SUB_PREFIX=$(${WP_CLI_Remote_Quick_SubSite} db prefix)
  MAIN_PREFIX=$(${WP_CLI_Localy_Quick} config get table_prefix --type=variable)

  if [[ "$SUB_PREFIX" == "$MAIN_PREFIX" ]]; then
    echo '  Importing all tables.'
    return
  fi

  NETWORK_TABLES="${MAIN_PREFIX}usermeta,${MAIN_PREFIX}users,${MAIN_PREFIX}signups,${MAIN_PREFIX}site,${MAIN_PREFIX}sitemeta,${MAIN_PREFIX}blogmeta,${MAIN_PREFIX}blogs"
  SUB_TABLES=$(${WP_CLI_Remote_Quick} db query "SHOW TABLES LIKE '${SUB_PREFIX}%';" --silent --skip-column-names | tr '\n' ',' | sed 's/,$//')

  echo -e "  Importing tables: ${C_ORN}${SUB_TABLES}${C_GRN}${NETWORK_TABLES}${C_OFF}"

  TARGET_TABLES="${SUB_TABLES},${NETWORK_TABLES}"
  TARGET_TABLES_SHORT="${SUB_PREFIX}*,${NETWORK_TABLES}"
}
