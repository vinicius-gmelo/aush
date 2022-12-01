aush_update ()
{
  if [ -z "$AUSH_STATUS" ]; then
    local downloaded_script_file
    cd "$AUSH_REPO"
    downloaded_script_file="$(find * -maxdepth 1 -type f -name ${AUSH_REPO}*)"
    if [ -n "$downloaded_script_file" ]; then
      export AUSH_UPDATED_SCRIPT_FILE="$(pwd)"/"$downloaded_script_file"
      if ! cmp --silent "$AUSH_ORIGINAL_SCRIPT_FILE" "$AUSH_UPDATED_SCRIPT_FILE"; then
        export AUSH_STATUS='updating'
        [ ! -s "$(dirname ${AUSH_UPDATED_SCRIPT_FILE})/lib/aush_source.sh" ] && aush "$AUSH_UPDATED_SCRIPT_FILE"
        chmod +x "$AUSH_UPDATED_SCRIPT_FILE"
        "$AUSH_UPDATED_SCRIPT_FILE" "$@"
        exit 0
      else
        return 0
      fi
    else
      return 1
    fi
  else
    export AUSH_STATUS='done'
    cp "$AUSH_UPDATED_SCRIPT_FILE" "$AUSH_ORIGINAL_SCRIPT_FILE"
    cd $(dirname "$AUSH_ORIGINAL_SCRIPT_FILE")
    "$AUSH_ORIGINAL_SCRIPT_FILE" "$@"
    rm -rf $(dirname "$AUSH_UPDATED_SCRIPT_FILE")
    exit 0
  fi
}

if ! . "${HOME}/.aush"; then
  printf 'aush: could not read "${HOME}/.aush", please config aush with "aush config"\n'
else
  if [ -z "$AUSH_STATUS" ]; then
    aush_original_script_basename="$(basename $0)"
    export AUSH_REPO="${aush_original_script_basename%.*}"
    export AUSH_ORIGINAL_SCRIPT_FILE="$(dirname $(which $0))"/"$aush_original_script_basename"
    printf 'aush: checking updates for "%s" from "%s" repo\n' "$AUSH_ORIGINAL_SCRIPT_FILE" "$AUSH_REPO"
    cd '/tmp'
    [ -d "$AUSH_REPO" ] && rm -fr "$AUSH_REPO"
    if git clone "$aush_remote_git_account"/"$AUSH_REPO".git 2>/dev/null; then
      if ! aush_update "$@"; then
        printf 'aush: could not update; could not find "%s", "%s.sh" or "%s.bash" on repo\n' "$AUSH_REPO" "$AUSH_REPO" "$AUSH_REPO"
      fi
    else
      printf 'aush: could not update; error while cloning "%s" repo from "%s" account (check if repo/account exist)\n' "$AUSH_REPO" "$AUSH_HTTPS_ACCOUNT"
    fi
  elif [ $AUSH_STATUS = 'updating' ]; then
    printf 'aush: updating "%s"\n' "$AUSH_ORIGINAL_SCRIPT_FILE"
    aush_update "$@"
  else
    printf 'aush: "%s" updated succesfully!\n' "$AUSH_ORIGINAL_SCRIPT_FILE"
  fi
  unset AUSH_STATUS AUSH_ORIGINAL_SCRIPT_FILE AUSH_UPDATED_SCRIPT_FILE
fi
unset aush_remote_git_account
echo
