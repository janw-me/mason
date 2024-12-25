#!/usr/bin/env bash

function deactivate_plugins() {
  echo 'Deactivating plugins'

  declare -a plugins=(
    all-in-one-wp-security-and-firewall
    autoptimize
    better-wp-security
    coming-soon
    easy-wp-smtp
    fluent-smtp
    ithemes-security-pro
    litespeed-cache
    limit-login-attempts-reloaded
    mailgun
    mainwp-child
    post-smtp
    query-monitor
    restricted-site-access
    smtp-mailer
    sparkpost
    under-construction-page
    w3-total-cache
    worker
    wordfence
    wp-cerber
    wp-fastest-cache
    wp-mail-smtp
    wp-offload-ses
    wp-rocket
    wp-ses
    wp-staging-pro
    wp-super-cache
  )

  PLUGIN_LIST=''
  for plugin in "${plugins[@]}"; do
    PLUGIN_LIST+=" $plugin"
  done

  # if subsite, only check that, and network.
  if [[ ! -z "$SUB_SITE" ]]; then
    ${WP_CLI_Localy_Quick} plugin deactivate ${PLUGIN_LIST}
    ${WP_CLI_Localy_Quick_SubSite} plugin deactivate ${PLUGIN_LIST} --network
    return
  fi

  if ! ${WP_CLI_Localy_Quick} core is-installed --network; then
      ${WP_CLI_Localy_Quick} plugin deactivate ${PLUGIN_LIST}
      return; # don't check further.
  fi

  ${WP_CLI_Localy_Quick} plugin deactivate ${PLUGIN_LIST} --network
  # loop over all sites.
  for site in $(${WP_CLI_Localy_Quick} site list --field=url --format=csv); do
    ${WP_CLI_Localy_Quick} plugin deactivate ${PLUGIN_LIST} --url=$site
  done
}
