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
  cp "$(dirname $(which aush))/aush_source.sh" "$source_file"
  return 0
}

add_source ()
{
  if grep 'aush_source.sh' $script_file >/dev/null; then
    printf 'aush: "%s" already sources an aush source file; do not add duplicate to code\n' "$script_file"
    if [ ! -s './lib/aush_source.sh' ]; then 
      printf 'aush: could not find a "./lib/aush_source.sh" relative to "%s"; creating it\n' "$script_file"
      if create_source_file; then
        printf 'aush: "%s" created succesfully' "$source_file"
        return 0
      else
        printf 'aush: could not create source file'
        return 1
      fi
    else
      printf 'aush: "%s" already have an aush source file, skip creating it' "$script_file"
      return 0
    fi
  fi
  local first_line
  first_line="$(head -n1 $script_file)"
  if [ "$(echo "$first_line" | cut -c1-2)" = '#!' ]; then
    lang=$(echo "$first_line" | cut -c 3- | xargs basename)
    if [ "$lang" = 'sh' ] || [ "$lang" = 'bash' ]; then
      create_source_file
      # add source after shbang
      sed "1a\|\# aush - https://github.com/vinicius-gmelo/aush; run before any commands\|\.\ $source_file" "$script_file" | tr '|' '\n' > "${script_file}.tmp" && mv "${script_file}.tmp" "$script_file"
      return 0
    else
      printf 'aush: aush is made for shell/bash scripts.\n'
      return 1
    fi
  else
    printf 'aush: "%s" does not seem to be a script... aush it anyway [y/N]? ' "$script_file"
    read -r add_anyway
    case "$add_anyway" in

      Y|y|YY|yy)
        create_source_file
        # add source to beginning of script
        sed "1i\# aush - https://github.com/vinicius-gmelo/aush; run before any commands\|\.\ $source_file\|" "$script_file" | tr '|' '\n' > "${script_file}.tmp" && mv "${script_file}.tmp" "$script_file"
        return 0
        ;;

      N|n|NN|nn|'')
        return 1
        ;;

    esac
  fi
  return 1
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
    if aush_update_dir="$(dirname $(which aush))"; then
      cd '/tmp'
      [ -d 'aush' ] && rm -fr 'aush'
      git clone https://github.com/vinicius-gmelo/aush.git 2>/dev/null && cd 'aush' || exit 1
      chmod +x 'aush.sh'
      cp 'aush.sh' "${aush_update_dir}/aush"
      cp 'aush_source.sh' "$aush_update_dir"
      printf 'aush: aush updated succesfully!\n'
      exit 0
    else
      printf 'aush: aush is not set as a shell command on your shell, please follow the instructions on https://github.com/vinicius-gmelo/aush'
      exit 1
    fi
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
    if add_source; then
      exit 0
    else
      exit 1
    fi
    ;;

esac
