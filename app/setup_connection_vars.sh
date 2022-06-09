#!/usr/bin/env bash

function setup_connection_vars {
  wp cli alias get @live &> /dev/null
  if [[ $? -eq 1 ]]; then
      echo -e "${C_RED}Error:${C_OFF} can't find alias @live, check your ${C_ORN}wp-cli.yml${C_OFF} file"
      exit;
  fi

  # Get all @live vars
  LIVE_SSH=$(            wp eval --skip-wordpress 'echo \WP_CLI::get_configurator()->get_aliases()["@live"]["ssh"];' );
  LIVE_URL=$(basename $( wp @live option get home) );
  LIVE_PATH=$(           wp eval --skip-wordpress 'echo \WP_CLI::get_configurator()->get_aliases()["@live"]["path"];' );
  # Set all local vars
  LOCAL_URL=$(basename $( wp option get home ) );
  LOCAL_PATH=$(          wp eval 'echo ABSPATH;' );

  #force Trailing slash
  LIVE_PATH=${LIVE_PATH%/}/
  LOCAL_PATH=${LOCAL_PATH%/}/
}