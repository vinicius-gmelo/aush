if ! . "${HOME}/.aush"; then
  printf 'aush: could not read "${HOME}/.aush", please config aush with "aush config"\n'
else
  case "$AUSH_STATUS" in

    '')
      # startup vars used by child processes so that they know the original files
      aush_original_script_basename="$(basename $0)"
      export AUSH_REPO="${aush_original_script_basename%.*}"
      export AUSH_ORIGINAL_SCRIPT_FILE="$(dirname $(which $0))"/"$aush_original_script_basename"
      printf 'aush: checking updates for "%s" from "%s" repo\n' "$AUSH_ORIGINAL_SCRIPT_FILE" "$AUSH_REPO"
      cd '/tmp'
      [ -d "$AUSH_REPO" ] && rm -fr "$AUSH_REPO"
      # only start aush_update if git clone works
      if git clone "$aush_remote_git_account"/"$AUSH_REPO".git 2>/dev/null; then
        cd "$AUSH_REPO"
        aush_downloaded_script_file="$(find * -maxdepth 1 -type f -name ${AUSH_REPO}*)"
        if [ -n "$aush_downloaded_script_file" ]; then
          export AUSH_UPDATED_SCRIPT_FILE="$(pwd)"/"$aush_downloaded_script_file"
          # check if file needs update
          if ! cmp --silent "$AUSH_ORIGINAL_SCRIPT_FILE" "$AUSH_UPDATED_SCRIPT_FILE"; then
            # start update
            [ ! -s "$(dirname ${AUSH_UPDATED_SCRIPT_FILE})/lib/aush_source.sh" ] && aush "$AUSH_UPDATED_SCRIPT_FILE"
            # change status and run downloaded script
            export AUSH_STATUS='updating'
            "$AUSH_UPDATED_SCRIPT_FILE" "$@"
            # kill parent process
            exit 0
          fi
        else
          # could not find corresponding shell script on repo's root dir
          printf 'aush: could not update; could not find "%s", "%s.sh" or "%s.bash" on repo\n' "$AUSH_REPO" "$AUSH_REPO" "$AUSH_REPO"
        fi
      else
        printf 'aush: could not update; error while cloning "%s" repo from "%s" account (check if repo/account exist)\n' "$AUSH_REPO" "$AUSH_HTTPS_ACCOUNT"
      fi
      ;;

    updating)
      printf 'aush: updating "%s"\n' "$AUSH_ORIGINAL_SCRIPT_FILE"
      cp "$AUSH_UPDATED_SCRIPT_FILE" "$AUSH_ORIGINAL_SCRIPT_FILE"
      cd $(dirname "$AUSH_ORIGINAL_SCRIPT_FILE")
      # update source line on updated script file
      sed -i "/\#\ aush/,+1d" "$AUSH_ORIGINAL_SCRIPT_FILE"
      aush "$AUSH_ORIGINAL_SCRIPT_FILE"
      # change status and run updated script
      export AUSH_STATUS='done'
      "$AUSH_ORIGINAL_SCRIPT_FILE" "$@"
      # cleanup downloaded files
      rm -rf $(dirname "$AUSH_UPDATED_SCRIPT_FILE")
      # kill parent process
      exit 0
      ;;

    done)
      printf 'aush: "%s" updated succesfully!\n' "$AUSH_ORIGINAL_SCRIPT_FILE"
      ;;

  esac
  # update finished, clean vars
  unset AUSH_STATUS AUSH_ORIGINAL_SCRIPT_FILE AUSH_UPDATED_SCRIPT_FILE aush_downloaded_script_file
fi
unset aush_remote_git_account
echo
