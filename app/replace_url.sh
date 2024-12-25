#!/usr/bin/env bash

function replace_url() {
  # we need the prefix to be the same, before we can do a search-replace.
  ${WP_CLI_Localy_Quick} config set table_prefix --type=variable $(${WP_CLI_Remote_Quick} config get table_prefix --type=variable)
  ${WP_CLI_Localy_Quick} config set DB_CHARSET $(${WP_CLI_Remote_Quick} config get DB_CHARSET)

  # include tables
  if [[ -z "${TARGET_TABLES_SHORT}" ]]; then
    INCLUDE_TABLES='--all-tables'
  else
    INCLUDE_TABLES="--all-tables ${TARGET_TABLES_SHORT//,/ }" # Yes even when tables are specified, --all-tables is needed.
  fi

  echo -e "replacing main URL ${C_GRN}${LIVE_URL}${C_OFF} with ${C_ORN}${LOCAL_URL}${C_OFF}"
  ${WP_CLI_Localy_Fully} search-replace "${LIVE_URL}"          "${LOCAL_URL}"        --report-changed-only ${INCLUDE_TABLES}
  ${WP_CLI_Localy_Fully} search-replace "https://${LOCAL_URL}" "http://${LOCAL_URL}" --report-changed-only ${INCLUDE_TABLES}

  if [[ $(jq -r '.mason .extra_domains' <<<"$WP_CLI_JSON") != "null" ]]; then
    # Extract the keys and values from the extra_domains object
    ORIGINAL_URL=($(jq -r '.mason .extra_domains | keys_unsorted[]' <<<"$WP_CLI_JSON"))
    NEW_URL=($(jq -r '.mason .extra_domains[]' <<<"$WP_CLI_JSON"))

    # Iterate over the keys and values
    for ((i=0; i<${#ORIGINAL_URL[@]}; i++)); do
      echo -e "replacing ${C_GRN}${ORIGINAL_URL[i]}${C_OFF} with ${C_ORN}${NEW_URL[i]}${C_OFF}"
      ${WP_CLI_Localy_Fully} search-replace "${ORIGINAL_URL[i]}"    "${NEW_URL[i]}"        --report-changed-only ${INCLUDE_TABLES}
      ${WP_CLI_Localy_Fully} search-replace "https://${NEW_URL[i]}" "http://${NEW_URL[i]}" --report-changed-only ${INCLUDE_TABLES}
    done
  fi
}
