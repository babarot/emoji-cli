#
#                        _ _            _ _   
#                       (_|_)          | (_)  
#    ___ _ __ ___   ___  _ _ ______ ___| |_   
#   / _ \ '_ ` _ \ / _ \| | |______/ __| | |  
#  |  __/ | | | | | (_) | | |     | (__| | |  
#   \___|_| |_| |_|\___/| |_|      \___|_|_|  
#                      _/ |                   
#                     |__/                    
#

EMOJI_CLI_DICT="${0:A:h}/dict/emoji.json"
: "${EMOJI_CLI_FILTER:="fzf:peco:percol"}"
: "${EMOJI_CLI_KEYBIND:="^s"}"

# helper functions
is_zsh()  { [ -n "$ZSH_VERSION" ];  }
available() {
    local x candidates

    # candidates should be list like "a:b:c" concatenated by a colon
    candidates="$1:"

    while [ -n "$candidates" ]; do
        # the first remaining entry
        x=${candidates%%:*}
        # reset candidates
        candidates=${candidates#*:}

        # check if x is available
        if has "$x"; then
            echo "$x"
            return 0
        else
            continue
        fi
    done

    return 1
}

# unique EMOJI_CLI_FILTER
_EMOJI_CLI_FILTER="$(available "$EMOJI_CLI_FILTER")"

emoji::emoji_get() {
    cat <"$EMOJI_CLI_DICT" \
        | jq -r '.[]|"\(.emoji) \(":" + .aliases[0] + ":")"' \
        | eval "$_EMOJI_CLI_FILTER" \
        | awk '{print $2}'
}

emoji::emoji_get_with_tag() {
    local filter
    filter="$(available "$EMOJI_CLI_FILTER")"

    cat <"$EMOJI_CLI_DICT" \
        | jq -r '.[] | select(.tags[],.aliases[]|contains("'"$1"'"))| "\(.emoji) \(":" + .aliases[0] + ":")"' \
        | sort -k2,2 \
        | uniq \
        | eval "$_EMOJI_CLI_FILTER" \
        | awk '{print $2}'
}

emoji::cli() {
    local emoji
    local _BUFFER _RBUFFER _LBUFFER

    _RBUFFER=$RBUFFER
    if [[ -n $LBUFFER ]]; then
        _LBUFFER=${LBUFFER##* }
        if [[ $_LBUFFER =~ [a-zA-z0-9+_-]$ ]]; then
            local comp
            comp="$(echo $_LBUFFER | grep -E -o ":?[a-zA-z0-9+_-]+")"
            emoji="$(emoji::emoji_get_with_tag "${(L)comp#:}")"
            _BUFFER="${LBUFFER%$comp}${emoji:-$comp}"
        else
            emoji="$(emoji::emoji_get)"
            _BUFFER="${LBUFFER}${emoji}"
        fi
    else
        emoji="$(emoji::emoji_get)"
        _BUFFER="${emoji}"
    fi

    if [[ -n "$_RBUFFER" ]]; then
        BUFFER=$_BUFFER$_RBUFFER
    else
        BUFFER=$_BUFFER
    fi

    CURSOR=$#_BUFFER
    zle clear-screen
}

# source only
if [[ ! $- =~ i ]]; then
    echo "this script requires interactive shell mode" 1>&2
    exit 1
fi

# zsh only
if ! is_zsh; then
    echo "this script requires zsh" 1>&2
    return 1
fi

if (( ! $+commands[jq] )); then
    echo "jq: not found" 1>&2
    return 1
fi

if [[ -z $_EMOJI_CLI_FILTER ]] || (( ! $+commands[$_EMOJI_CLI_FILTER] )); then
    echo "$EMOJI_CLI_FILTER: not available as an interactive filter command" 1>&2
    return 1
fi
# settings for keybind
zle -N emoji::cli
bindkey "$EMOJI_CLI_KEYBIND" emoji::cli

# vim:ft=zsh
