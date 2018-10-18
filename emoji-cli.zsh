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
: "${EMOJI_CLI_FILTER:="fzf-tmux -d 15%:fzf:peco:percol:fzy"}"
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
        if (( $+commands[${x%% *}] )); then
            echo "$x"
            return 0
        else
            continue
        fi
    done

    return 1
}

emoji::fuzzy() {
    awk -v search_string="${1:?too few arguments}" '
    {
        # calculates the degree of similarity
        if ( (1 - leven_dist($0, search_string) / (length($0) + length(search_string))) * 100 >= 70 ) {
            # When the degree of similarity of search_string is greater than or equal to 70%,
            # to display the candidate path
            print $0
        }
    }

    # leven_dist returns the Levenshtein distance two text string
    function leven_dist(a, b) {
        lena = length(a);
        lenb = length(b);

        if (lena == 0) {
            return lenb;
        }
        if (lenb == 0) {
            return lena;
        }

        for (row = 1; row <= lena; row++) {
            m[row,0] = row
        }
        for (col = 1; col <= lenb; col++) {
            m[0,col] = col
        }

        for (row = 1; row <= lena; row++) {
            ai = substr(a, row, 1)
            for (col = 1; col <= lenb; col++) {
                bi = substr(b, col, 1)
                if (ai == bi) {
                    cost = 0
                } else {
                    cost = 1
                }
                m[row,col] = min(m[row-1,col]+1, m[row,col-1]+1, m[row-1,col-1]+cost)
            }
        }

        return m[lena,lenb]
    }

    # min returns the smaller of x, y or z
    function min(a, b, c) {
        result = a

        if (b < result) {
            result = b
        }

        if (c < result) {
            result = c
        }

        return result
    }' 2>/dev/null
}

emoji::emoji_get() {
    # reset filter
    _EMOJI_CLI_FILTER="$(available "$EMOJI_CLI_FILTER")"

    cat <"$EMOJI_CLI_DICT" \
        | jq -r '.[]|"\(.emoji) \(":" + .aliases[0] + ":")"' \
        | eval "$_EMOJI_CLI_FILTER" \
        | awk '{print $2}'
}

emoji::emoji_get_with_tag() {
    # reset filter
    _EMOJI_CLI_FILTER="$(available "$EMOJI_CLI_FILTER")"

    local tmp
    tmp="$(jq -r '.[] | select(.tags[],.aliases[]|contains("'"$1"'")) | "\(.emoji) \(":" + .aliases[0] + ":")"' "$EMOJI_CLI_DICT")"
    if [[ -n $tmp ]]; then
        echo "$tmp"
    else
        local candidates i
        candidates=($(jq -r '[.[] | .tags[]] | sort | unique | .[]' "$EMOJI_CLI_DICT" | emoji::fuzzy "$1"))
        for i in "${candidates[@]}"; do
            cat <"$EMOJI_CLI_DICT" \
                | jq -r '.[] | select(.tags[],.aliases[]|contains("'"$i"'"))| "\(.emoji) \(":" + .aliases[0] + ":")"'
        done
    fi | sort -k2,2 \
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
        if [[ $_LBUFFER =~ [a-zA-Z0-9+_-]$ ]]; then
            local comp
            comp="$(echo $_LBUFFER | grep -E -o ":?[a-zA-Z0-9+_-]+")"
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
    zle reset-prompt
}

# source only
if [[ ! $- =~ i ]]; then
    echo "this script requires interactive shell mode" 1>&2
    return 1
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

if (( ! $+commands[${"$(available "$EMOJI_CLI_FILTER")"%% *}] )); then
    echo "$EMOJI_CLI_FILTER: not available as an interactive filter command" 1>&2
    return 1
fi
# settings for keybind
zle -N emoji::cli
bindkey "$EMOJI_CLI_KEYBIND" emoji::cli

# vim:ft=zsh
