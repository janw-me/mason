#!/usr/bin/env bash

function update_wp_config() {
  #DB prefix is done in the replace_url.sh

  if ${WP_CLI_Localy_Quick} config has FORCE_SSL_ADMIN; then
    ${WP_CLI_Localy_Quick} config set FORCE_SSL_ADMIN false --raw
  fi

  ############################################################
  # Sync multisite constants
  ############################################################
  if ${WP_CLI_Remote_Quick} config has WP_ALLOW_MULTISITE; then
    WP_ALLOW_MULTISITE=$(${WP_CLI_Remote_Quick} config get WP_ALLOW_MULTISITE)
    WP_ALLOW_MULTISITE=$( [ "$WP_ALLOW_MULTISITE" == '1' ] && echo true || echo false )

    ${WP_CLI_Localy_Quick} config set WP_ALLOW_MULTISITE $WP_ALLOW_MULTISITE --raw
  fi
  if ${WP_CLI_Remote_Quick} config has MULTISITE; then
    MULTISITE=$(${WP_CLI_Remote_Quick} config get MULTISITE)
    MULTISITE=$( [ "$MULTISITE" == '1' ] && echo true || echo false )
    ${WP_CLI_Localy_Quick} config set MULTISITE $MULTISITE --raw
  fi
  if ${WP_CLI_Remote_Quick} config has SUBDOMAIN_INSTALL; then
    SUBDOMAIN_INSTALL=$(${WP_CLI_Remote_Quick} config get SUBDOMAIN_INSTALL)
    SUBDOMAIN_INSTALL=$( [ "$SUBDOMAIN_INSTALL" == '1' ] && echo true || echo false )
    ${WP_CLI_Localy_Quick} config set SUBDOMAIN_INSTALL $SUBDOMAIN_INSTALL --raw
  fi
  if ${WP_CLI_Remote_Quick} config has PATH_CURRENT_SITE; then
    ${WP_CLI_Localy_Quick} config set PATH_CURRENT_SITE $(${WP_CLI_Remote_Quick} config get PATH_CURRENT_SITE)
  fi
  if ${WP_CLI_Remote_Quick} config has SITE_ID_CURRENT_SITE; then
    ${WP_CLI_Localy_Quick} config set SITE_ID_CURRENT_SITE $(${WP_CLI_Remote_Quick} config get SITE_ID_CURRENT_SITE) --raw
  fi
  if ${WP_CLI_Remote_Quick} config has BLOG_ID_CURRENT_SITE; then
    ${WP_CLI_Localy_Quick} config set BLOG_ID_CURRENT_SITE $(${WP_CLI_Remote_Quick} config get BLOG_ID_CURRENT_SITE) --raw
  fi
  if ${WP_CLI_Remote_Quick} config has DOMAIN_CURRENT_SITE; then
    # replace the domain with the local domain
    PREFIX=$(${WP_CLI_Localy_Quick}  db prefix)
    SITE_ID=$(${WP_CLI_Localy_Quick}  config get SITE_ID_CURRENT_SITE)
    BLOG_ID=$(${WP_CLI_Localy_Quick}  config get BLOG_ID_CURRENT_SITE)
    DOMAIN_CURRENT_SITE=$(${WP_CLI_Localy_Quick}  db query "SELECT domain FROM ${PREFIX}blogs WHERE blog_id = ${BLOG_ID} AND site_id = ${SITE_ID}" --skip-column-names)
    ${WP_CLI_Localy_Quick}  config set DOMAIN_CURRENT_SITE $DOMAIN_CURRENT_SITE
  fi

  ############################################################
  # Set extra config variables and constants
  ############################################################
  if [[ $(jq -r '.mason .extra_config' <<<"$WP_CLI_JSON") != "null" ]]; then
    # Extract the keys and values from the extra_config object
    VARS_CONSTS=($(jq -r '.mason .extra_config | keys_unsorted[]' <<<"$WP_CLI_JSON"))
    VALUES=($(jq '.mason .extra_config[]' <<<"$WP_CLI_JSON"))

    # Iterate over the keys and values
    for ((i=0; i<${#VARS_CONSTS[@]}; i++)); do
      echo -e "Setting  ${C_GRN}${VARS_CONSTS[i]}${C_OFF} to ${C_ORN}${VALUES[i]}${C_OFF}"

      # Const or var?
      if [[ ${VARS_CONSTS[i]} == \$* ]]; then
        TYPE="--type=variable"
        KEY="${VARS_CONSTS[i]:1}"  # Remove the leading dollar sign
      else
        TYPE="--type=constant"
        KEY="${VARS_CONSTS[i]}"
      fi

      if [[ "${VALUES[i]}" == '"@SYNC"' ]]; then
        # Try to get the value from the live site.
        if ( ${WP_CLI_Remote_Quick} config has ${KEY} ); then
          SYNC_VALUE=$(${WP_CLI_Remote_Quick} config get ${KEY} --format=json ${TYPE})
          ${WP_CLI_Localy_Quick} config set ${KEY} "${SYNC_VALUE}" --raw ${TYPE}
        else
          echo -e "${C_RED}ERROR: ${C_OFF} ${C_GRN}${KEY}${C_OFF} is empty on live site."
        fi
      else
        # Flat sync from wp-cli.yml
        ${WP_CLI_Localy_Quick} config set ${KEY} "${VALUES[i]}" --raw ${TYPE}
      fi
    done
  fi
}
