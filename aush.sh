#!/bin/sh

create_source_file ()
{
  lib_dir="$(dirname \"$script_file\")"
  source_file="${lib_dir}/lib/aush.sh"
  [ ! -d "$lib_dir" ] && mkdir "$lib_dir"
  cat << 'EOF' > "$source_file"
aush_update ()
{
local scargs
script_file="$1"
git_file="$2"
script_args="$3"
if [ -z "$AUSH_UPDATE" ]; then
  export AUSH_UPDATE=1
  cp "${aush_script_file}" "${aush_script_file}".bak
  "${aush_git_file}" "$@" &
  exit 0
else
  cp "${aush_git_file}" "${aush_script_file}"
fi
}

cd /tmp
aush_script_file=$(basename "$0")
aush_repo="${aush_script_file%.*}"
printf 'aush: updating %s from %s' "$aush_script_file" "$aush_repo"
gh repo clone $aush_gh_repo && cd $aush_gh_repo || exit 1
aush_git_file="$(pwd)"/"$aush_script_file"
cmp --silent "$aush_script_file" "$aush_git_file"
if [ $? -eq 1 ]; then
aush_update "$@"
fi
EOF
  exit $?
}

add_source ()
{
  local first_line
  first_line=$(head -n1 "$script_file")
  if [ "$(echo "$first_line" | cut -c1-2)" = '#!' ]; then
    lang=$(echo "$first_line" | cut -c 3- | xargs basename)
    if [ "$lang" = sh ] || [ "$lang" = bash ]; then
      create_source_file
      # add source after shbang
      sed "1a\|\# aush must run before any other command\|\.\ $source_file" "$script_file" | tr '|' '\n' > "${script_file}.tmp" && mv "${script_file}.tmp" "$script_file"
      exit 0
    else
      printf 'aush is made for shell/bash scripts.\n'
      exit 1
    fi
  else
    printf '%s does not seem to be a script... add a source to it anyway [y/N]? ' "$script_file"
    read -r add_anyway
    case "$add_anyway" in
      Y|y|YY|yy)
        create_source_file
        # add source to beginning of script
        sed "1i\# aush must run before any other command\|\.\ $source_file\|" "$script_file" | tr '|' '\n' > "${script_file}.tmp" && mv "${script_file}.tmp" "$script_file"
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
  printf "aush [script|help]" && exit 1
fi

  script_file=$1
if [ -s $1 ]; then
  echo $1
  add_source $1
else
  case "$1" in
    update)
      update_script $2 $3
      exit 0
      ;;
    help)
      echo help
      exit 0
      ;;
    *)
      echo 'please try again'
      exit 1
      ;;
  esac
fi
