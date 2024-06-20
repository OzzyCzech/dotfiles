function  encode64() {
  if [ -f "$1" ]; then

    local mime;
    mime=$(file -b --mime-type "$1")

    if [[ $mime == text/* ]]; then
        mime="${mime};charset=utf-8"
    fi

    printf "data:${mime};base64,%s" "$(base64 -i "$1")"
  else
    if [[ $# -eq 0 ]]; then
      cat | base64
    else
      printf '%s' "$1" | base64
    fi
  fi
}

alias e64=encode64