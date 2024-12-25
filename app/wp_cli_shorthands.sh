#!/usr/bin/env bash

#######################################
# All shorthands for wp-cli commands

function wp_cli_shorthands() {
  URL_FLAG_REMOTE="" # Default no flag.
  if [[ ! -z "${SUB_SITE}" ]]; then
    # Local will only get set later.
    URL_FLAG_REMOTE="--url=${SUB_SITE}"
  fi
  WP_CLI_Localy_Fully="wp "
  WP_CLI_Localy_Quick="wp --skip-plugins --skip-themes "
  WP_CLI_Remote_Fully="wp @live "
  WP_CLI_Remote_Quick="wp @live --skip-plugins --skip-themes "
  WP_CLI_Remote_Fully_SubSite="wp @live ${URL_FLAG_REMOTE} "
  WP_CLI_Remote_Quick_SubSite="wp @live --skip-plugins --skip-themes ${URL_FLAG_REMOTE} "
}

# After the search-replaces the SUB_SITE is no longer the same as the remote.
function wp_cli_shorthands_rerender() {
  if [[ ! -z "${SUB_SITE}" ]]; then
    LOCAL_SUB_SITE="$(wp site url ${SUB_SITE_ID} --skip-plugins --skip-themes)"
    URL_FLAG_LOCALY="--url=${LOCAL_SUB_SITE}"
  fi
  WP_CLI_Localy_Fully_SubSite="wp ${URL_FLAG_LOCALY} "
  WP_CLI_Localy_Quick_SubSite="wp --skip-plugins --skip-themes ${URL_FLAG_LOCALY} "
}
