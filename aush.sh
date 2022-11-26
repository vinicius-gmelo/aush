if [ $(basename $0) = 'aush' ] || [ $(basename $0) = 'aush.sh' ]; then

  add_source ()
  {
    local script_file
    local first_line
    script_file=$1
    first_line=$(head -n1 $script_file)
    if [ "$(echo $first_line | cut -c1-2)" = '#!' ]; then
      lang=$(echo $first_line | cut -c 3- | xargs basename)
      if [ $lang = sh ] || [ $lang = bash ]; then
        sed "1a\|\# aush must run before any other command\|\.\ $0" $script_file | tr '|' '\n' > ${script_file}.tmp && mv ${script_file}.tmp $script_file
        exit 0
      else
        printf 'aush is made for shell/bash scripts.\n'
        exit 1
      fi
    else
      printf '%s does not seem to be a script... add a source to it anyway [y/N]? ' "$script_file"
      read add_source
      case "$add_source" in
        Y|y)
          sed "1i\# aush must run before any other command\|\.\ $0\|" $script_file | tr '|' '\n' > ${script_file}.tmp && mv ${script_file}.tmp $script_file
          exit 0
          ;;
        N|n|'')
          exit 1
          ;;
      esac
    fi
    exit 1
  }

  if [ -s $1 ]; then
    echo $1
    add_source $1
  else
    case "$1" in
      set)
        echo set
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
else
  echo 'do the autoupdate'
  exit 1
fi
