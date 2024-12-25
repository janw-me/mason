#!/usr/bin/env bash

function validate_variables() {
  echo -e "Syncing with the following variables:"
  echo -e ''
  echo -e "Live domainname:      ${C_GRN}${LIVE_URL}${C_OFF}"
  echo -e "Live ssh connection:  ${C_GRN}${LIVE_SSH}${C_OFF}"
  echo -e "Live path:            ${C_GRN}${LIVE_PATH}${C_OFF}"
  echo -e ''
  echo -e "Local domainname:     ${C_GRN}${LOCAL_URL}${C_OFF}"
  echo -e "Local path:           ${C_GRN}${LOCAL_PATH}${C_OFF}"

  if [[ $(jq -r '.mason .extra_domains' <<<"$WP_CLI_JSON") == "null" ]]; then
    echo -e "No extra domains found in wp-cli.yml file(s)."
  else
    echo -e "Extra domains found in wp-cli.yml file(s):"
    ORIGINAL_URL=($(jq -r '.mason .extra_domains | keys_unsorted[]' <<<"$WP_CLI_JSON"))
    NEW_URL=($(jq -r '.mason .extra_domains[]' <<<"$WP_CLI_JSON"))

    # Iterate over the keys and values
    for ((i=0; i<${#ORIGINAL_URL[@]}; i++)); do
      echo -e "  replacing ${C_GRN}${ORIGINAL_URL[i]}${C_OFF} with ${C_ORN}${NEW_URL[i]}${C_OFF}"
    done
    echo -e ''
  fi

  validate_multisite

  while true; do
    read -p "$(echo -e Are the connection details above correct? ${C_ORN}[y/N]${C_OFF}) " yn
    case $yn in
    [Yy]*)
      break
      ;; #yes, continue.
    *)
      echo -e "Check the ${C_ORN}wp-cli.yml${C_OFF} and that the local site is running."
      exit 1
      ;; # the user found an error.
    esac
  done
}

function validate_multisite() {
  SUB_SITE='' # Default no site.
  if ! wp @live config has MULTISITE --skip-plugins --skip-themes; then
    echo -e "This is ${C_GRN}not${C_OFF} a multisite install."
    return
  fi
  MULTISITE=$(wp @live config get MULTISITE --skip-plugins --skip-themes)
  MULTISITE=$( [ "$MULTISITE" == '1' ] && echo true || echo false )
  if [[ "$MULTISITE" == "false" ]]; then
    echo -e "This is ${C_GRN}not${C_OFF} a multisite install."
    return
  fi

  MS_SITE_LIST=$(wp @live site list --fields=blog_id,url --format=json --skip-plugins --skip-themes)
  echo -e "This is a ${C_GRN}multisite${C_OFF} install."
  BLOG_ID=($(jq -r '.[] | .blog_id' <<<"$MS_SITE_LIST"))
  SITE_URL=($(jq -r '.[] | .url' <<<"$MS_SITE_LIST"))

  # Iterate over the keys and values
  for ((i=0; i<${#BLOG_ID[@]}; i++)); do
    echo -e " ${C_GRN}${BLOG_ID[i]}${C_OFF}: ${C_ORN}${SITE_URL[i]}${C_OFF}"
  done
  echo -e ''

  while true; do
    read -p "$(echo -e Enter ${C_ORN}b_blog_id${C_OFF} subsite to sync a single site, ${C_ORN}empty${C_OFF} for all:) " b_ID
    
    if [[ -z "$b_ID" ]]; then
      echo -e "Syncing ${C_ORN}all${C_OFF} subsites."
      break
    elif [[ ! " ${BLOG_ID[@]} " =~ " ${b_ID} " ]]; then
      echo -e "blog_id : ${C_ORN}${b_ID}${C_OFF} not valid."
    else
      # get array key
      for ((i=0; i<${#BLOG_ID[@]}; i++)); do
        if [[ "${BLOG_ID[i]}" == "$b_ID" ]]; then
          break
        fi
      done
      echo -e "Syncing subsite ${C_GRN}${b_ID}${C_OFF} ${C_ORN}${SITE_URL[i]}${C_OFF}"

      SUB_SITE="${SITE_URL[i]}"

      echo $SUB_SITE


      break
    fi

  done
}
