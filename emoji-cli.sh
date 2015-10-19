is_bash() { [ -n "$BASH_VERSION" ]; }
is_zsh()  { [ -n "$ZSH_VERSION" ];  }

emoji_get() {
    cat <dist/emoji.json \
        | jq -r '.[]|"\(.emoji) \(":" + .aliases[0] + ":")"' \
        | fzf \
        | awk '{print $2}'
}

emoji_get_with_tag() {
    cat <dist/emoji.json \
        | jq -r '.[] | select(.tags[],.aliases[]|contains("'"$1"'"))| "\(.emoji) \(":" + .aliases[0] + ":")"' \
        | sort -k2,2 \
        | uniq \
        | fzf \
        | awk '{print $2}'
}

emoji-cli() {
    local emoji

    #if is_bash; then
    #    if [[ -n $emoji ]]; then
    #        READLINE_LINE="$LBUFFER $emoji"
    #        READLINE_POINT=${#READLINE_LINE}
    #    fi
    #elif is_zsh; then

    local _BUFFER _RBUFFER _LBUFFER
    _RBUFFER=$RBUFFER
    if [[ -n $LBUFFER ]]; then
        _LBUFFER=${LBUFFER##* }
        if [[ $_LBUFFER =~ [a-zA-z0-9+_-]$ ]]; then
            local comp
            comp="$(echo $_LBUFFER | grep -E -o ":?[a-zA-z0-9+_-]+")"
            emoji="$(emoji_get_with_tag "${comp#:}")"
            _BUFFER="${LBUFFER%$comp}${emoji:-$comp}"
        else
            emoji="$(emoji_get)"
            _BUFFER="${LBUFFER}${emoji}"
        fi
    else
        emoji="$(emoji_get)"
        _BUFFER="${emoji}"
    fi

    CURSOR=$#_BUFFER
    BUFFER=$_BUFFER$_RBUFFER
    zle clear-screen

    #else
    #    echo "bash or zsh" 1>&2
    #    return 1
    #fi
}

zle -N emoji-cli
bindkey "^j" emoji-cli

# vim:ft=zsh
