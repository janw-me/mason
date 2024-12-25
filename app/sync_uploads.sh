#!/usr/bin/env bash

function sync_uploads() {
  LIVE_SSH_SERVER=$(echo ${LIVE_SSH} | awk -F: '{print $1}')
  LIVE_SSH_PORT=$(echo ${LIVE_SSH} | awk -F: '{print $2}')
  PORT=''
  if [[ ! -z "${LIVE_SSH_PORT}" ]]; then
    # @link https://superuser.com/a/360986
    PORT="-e 'ssh -p ${LIVE_SSH_PORT}'"
  fi


  REMOTE_UPLOADS_DIR=$(${WP_CLI_Remote_Fully_SubSite} eval 'echo wp_get_upload_dir()["basedir"];')
  LOCALY_UPLOADS_DIR=$(${WP_CLI_Localy_Fully_SubSite} eval 'echo wp_get_upload_dir()["basedir"];')

  # Root protection
  if [[ -z "${LOCALY_UPLOADS_DIR}" ]]; then
    echo "Local uploads dir empty, aborting."
    return
  fi
  if [[ -z "${REMOTE_UPLOADS_DIR}" ]]; then
    echo "Remote uploads dir empty, aborting."
    return
  fi

  eval "rsync ${PORT} ${LIVE_SSH_SERVER}:${REMOTE_UPLOADS_DIR%/}/ ${LOCALY_UPLOADS_DIR/}/ --delete -Pqavz"
}
