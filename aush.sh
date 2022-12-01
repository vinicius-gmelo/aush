#!/bin/sh

set_config_file ()
{
  local aush_remote_git_account aush_config_file url
  aush_config_file="${HOME}/.aush"
  while :; do
    printf 'aush: please, enter the remote git account url (example: "https://github.com/username": '
    read url
    if curl --output /dev/null --silent --head --fail "$url"; then
      break
    else
      printf 'aush: please enter a valid url\n'
    fi
  done

  aush_remote_git_account="$url"

  cat << EOF > "$aush_config_file"
# aush config file
# see 'aush help' for info
aush_remote_git_account=${aush_remote_git_account%/}
EOF

  printf 'aush: configuration file generated succesfully ("%s")\n' "${HOME}/.aush"

  return 0
}

create_source_file ()
{
  local lib_dir
  source_file="$(dirname ${script_file})/lib/aush_source.sh"
  lib_dir="$(dirname $source_file)"
  [ ! -d "$lib_dir" ] && mkdir "$lib_dir"
  cat <<-'EOF' > "$source_file"
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
EOF
}

add_source ()
{
  if grep 'aush_source.sh' $script_file >/dev/null; then
    printf 'aush: "%s" already sources an aush source file; do not add duplicate to code\n' "$script_file"
    if [ ! -s './lib/aush_source.sh' ]; then 
      printf 'aush: could not find a "./lib/aush_source.sh" relative to "%s"; creating it\n' "$script_file"
      create_source_file
    fi
    return 1
  fi

  local first_line
  first_line="$(head -n1 $script_file)"
  if [ "$(echo "$first_line" | cut -c1-2)" = '#!' ]; then
    lang=$(echo "$first_line" | cut -c 3- | xargs basename)
    if [ "$lang" = 'sh' ] || [ "$lang" = 'bash' ]; then
      create_source_file
      # add source after shbang
      sed "1a\|\# aush - https://github.com/vinicius-gmelo/aush; run before any commands\|\.\ $source_file" "$script_file" | tr '|' '\n' > "${script_file}.tmp" && mv "${script_file}.tmp" "$script_file"
      exit 0
    else
      printf 'aush: aush is made for shell/bash scripts.\n'
      exit 1
    fi
  else
    printf 'aush: "%s" does not seem to be a script... aush it anyway [y/N]? ' "$script_file"
    read -r add_anyway
    case "$add_anyway" in
      Y|y|YY|yy)
        create_source_file
        # add source to beginning of script
        sed "1i\# aush - https://github.com/vinicius-gmelo/aush; run before any commands\|\.\ $source_file\|" "$script_file" | tr '|' '\n' > "${script_file}.tmp" && mv "${script_file}.tmp" "$script_file"
        exit 0
        ;;
      N|n|NN|nn|'')
        exit 1
        ;;
    esac
  fi
  exit 1
}

if [ $# -ne 1 ]; then
  printf "aush: usage: aush [script|config|update|help]\n" && exit 1
fi


case "$1" in
  config)
    if set_config_file; then
      exit 0
    fi
    exit 1
    ;;
  update)
    cd '/tmp'
    [ -d 'aush' ] && rm -fr 'aush'
    git clone https://github.com/vinicius-gmelo/aush.git 2>/dev/null
    cd 'aush'
    chmod +x 'aush.sh'
    cp 'aush.sh' "${HOME}/.local/bin/aush"
    printf 'aush: aush updated succesfully!\n'
    exit 0
    ;;
  help)
    cat << EOF
aush: usage: aush [script|config|update|help]
aush: description: 'aush' checks for updates of a script using a remote Git repo. 'aush script' creates and sources 'aush_source.sh' to the user's script, autoupdating the script based on a repo.
EOF
    exit 0
    ;;
  *)
    script_file="$1"
    add_source
    exit 1
    ;;
esac
