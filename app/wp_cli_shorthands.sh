#!/usr/bin/env bash

#######################################
# All shorthands for wp-cli commands

function wp_cli_shorthands() {

  URL_FLAG_LOCALY="" # Default no flag.
  URL_FLAG_REMOTE="" # Default no flag.
  if [[ "${SUB_SITE}" != "" ]]; then
    URL_FLAG_LOCALY="--url=$(wp       site url ${SUB_SITE} --skip-plugins --skip-themes)"
    URL_FLAG_REMOTE="--url=$(wp @live site url ${SUB_SITE} --skip-plugins --skip-themes)"
  fi

  WP_CLI_Localy_Fully="wp "
  WP_CLI_Localy_Quick="wp --skip-plugins --skip-themes "
  WP_CLI_Localy_Fully_SubSite="wp ${URL_FLAG_LOCALY}"
  WP_CLI_Localy_Quick_SubSite="wp --skip-plugins --skip-themes ${URL_FLAG_LOCALY}"
  WP_CLI_Remote_Fully="wp @live "
  WP_CLI_Remote_Quick="wp @live --skip-plugins --skip-themes "
  WP_CLI_Remote_Fully_SubSite="wp @live ${URL_FLAG_REMOTE}"
  WP_CLI_Remote_Quick_SubSite="wp @live --skip-plugins --skip-themes ${URL_FLAG_REMOTE}"

}
