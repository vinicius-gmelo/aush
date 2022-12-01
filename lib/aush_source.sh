# aush source file

aush_update ()
{
  if [ -z "$AUSH_STATUS" ]; then
    cd "$AUSH_GH_REPO"
    # works for 'script', 'script.sh' and 'script.bash' or any other ext - TODO: only .bash and .sh or no ext on find command -, from cloned repo...
    export AUSH_UPDATED_SCRIPT_FILE="$(pwd)"/"$(find * -maxdepth 1 -type f -name ${AUSH_GH_REPO}*)"
    if [ -n "$AUSH_UPDATED_SCRIPT_FILE" ]; then
      if ! cmp --silent "$AUSH_ORIGINAL_SCRIPT_FILE" "$AUSH_UPDATED_SCRIPT_FILE"; then
        export AUSH_STATUS='updating'
        # add this source to the updated file if it is not 'aushed'
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
if [ -z "$AUSH_STATUS" ]; then
  aush_original_script_basename="$(basename $0)"
  export AUSH_GH_REPO="${aush_original_script_basename%.*}"
  export AUSH_ORIGINAL_SCRIPT_FILE="$(pwd)"/"$aush_original_script_basename"
  printf 'aush: checking updates for "%s" from "%s" repo\n' "$AUSH_ORIGINAL_SCRIPT_FILE" "$AUSH_GH_REPO"
  # checks for a repo with the same name of the script, no extension, on user account
  if gh repo clone "$AUSH_GH_REPO" 2>/dev/null; then
    if ! aush_update "$@"; then
      printf 'aush: could not update; could not find "%s", "%s.sh" or "%s.bash" on repo\n' "$AUSH_GH_REPO" "$AUSH_GH_REPO" "$AUSH_GH_REPO"
    fi
  else
    printf 'aush: could not update; error while cloning "%s" repo (did you login with "gh auth login"?)\n' "$AUSH_GH_REPO"
  fi
elif [ $AUSH_STATUS = 'updating' ]; then
  printf 'aush: updating "%s"\n' "$AUSH_ORIGINAL_SCRIPT_FILE"
  aush_update "$@"
else
  printf 'aush: "%s" updated succesfully!\n' "$AUSH_ORIGINAL_SCRIPT_FILE"
fi
unset AUSH_STATUS AUSH_ORIGINAL_SCRIPT_FILE AUSH_UPDATED_SCRIPT_FILE
echo
