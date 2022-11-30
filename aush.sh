#!/bin/sh

create_source_file ()
{
  local source_file lib_dir
  source_file="$(dirname $script_file)/lib/aush_source.sh"
  lib_dir="$(dirname $source_file)"
  [ ! -d "$lib_dir" ] && mkdir "$lib_dir"
  cat << 'EOF' > "$source_file"
aush_update ()
{
if [ -z "$AUSH_UPDATE" ]; then
export AUSH_UPDATE=1
# add this source to the updated file if it it is not 'aushed'
if [ ! -s "$(dirname ${aush_updated_script_file})/lib/aush_source.sh" ]; then
aush "${aush_updated_script_file}"
fi
"${aush_updated_script_file}" "$@" &
exit 0
else
cp "${aush_updated_script_file}" "${aush_aushed_script_file}"
fi
}

aush_aushed_script_basename="$(basename $0)"
aush_aushed_script_file="$(pwd)"/"$aush_aushed_script_basename"
aush_gh_repo="${aush_aushed_script_basename%.*}"
printf 'aush: checking updates for %s from %s repo' "$aush_aushed_script_file" "$aush_gh_repo"
cd /tmp
# checks for a repo with the same name of the script, no extension, on user account
gh repo clone "$aush_gh_repo"
if [ $? -eq 0 ]; then
cd "$aush_gh_repo"
# works for 'script', 'script.sh' and 'script.bash' from cloned repo...
aush_updated_script_file="$(pwd)"/$(basename $(find . -maxdepth 1 -type f (-name "${aush_aushed_script_basename}" -o -name "${aush_aushed_script_basename}.sh" -o -name "${aush_aushed_script_basename}.bash"))
if [ -z "$aush_updated_script_file" ]
printf 'aush: could not update, error while checking downloaded script from repo; allowed extensions: .sh and .bash'
else
cmp --silent "$aush_aushed_script_file" "$aush_updated_script_file"
if [ $? -eq 1 ]; then
aush_update "$@"
fi
else
printf 'aush: could not update, error while cloning repo; did you logged in with "gh auth login"?'
fi
fi
cd $(dirname "$aush_aushed_script_file")
EOF
  exit $?
}

add_source ()
{
  local first_line
  first_line="$(head -n1 $script_file)"
  if [ "$(echo "$first_line" | cut -c1-2)" = '#!' ]; then
    lang=$(echo "$first_line" | cut -c 3- | xargs basename)
    if [ "$lang" = 'sh' ] || [ "$lang" = 'bash' ]; then
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

script_file="$1"
add_source
