# emoji-cli

`emoji-cli` provides input completion for emoji on the command line with an interactive filter.

## :memo: Description

Emoji (絵文字, Japanese pronunciation: [emodʑi]) are the ideograms or smileys used in Japanese electronic messages and Web pages, that are spreading outside Japan (ref: [Katy Perry - Roar (Lyric Video)](https://www.youtube.com/watch?v=e9SeJIgWRPk)).

Emoji are funny and make us want to use it :blush:. However, it is hard to use it on the command line. This is because the command line don't have input completion for emoji. Therefore, I developed this command line application `emoji-cli`.

***DEMO:***

![](https://raw.githubusercontent.com/b4b4r07/screenshots/master/emoji-cli/demo.gif)

## :trollface: Features

- :scream: Emoji on the command line
- :globe_with_meridians: Interactive filter
- :mag_right: Fuzzy search

Unfortunately, this application supports Z shell only now :bow:.

## :mag: Usage

To insert emoji to the command line, type ctrl-s ( <kbd>^s</kbd> ).

```console
$ git commit -m 'This docume^s ...
```

To collaborate [`emojify`](https://github.com/mrowa44/emojify) similar to `emoji-cli` in emoji appication:

```console
echo ":santa^s" | emojify
🎅
```

## :package: Installation

```console
$ git clone https://github.com/b4b4r07/emoji-cli
$ source ./emoji-cli/emoji-cli.sh
```

For [Antigen](https://github.com/zsh-users/antigen) user:

```console
$ antigen bundle b4b4r07/emoji-cli
```

### Dependencies

- [`jq`](https://stedolan.github.io/jq/)
- An interactive filter ([`fzf`](https://github.com/junegunn/fzf), [`peco`](https://github.com/peco/peco)...)

## :wrench: Setup

### `EMOJI_CLI_DICT`

It is defaults to `./dict/emoji.json`. `EMOJI_CLI_DICT` is a path to dictionary of emoji database file. It is written in JSON.

### `EMOJI_CLI_FILTER`

It is defaults to `fzf:peco:percol:gof`. `EMOJI_CLI_FILTER` is the interactive filter command in order to use select emoji. It is separated by colon like the `PATH` environment variable.

### `EMOJI_CLI_KEYBIND`

It is defaults to `^s` (ctrl-s). `EMOJI_CLI_KEYBIND` is the key binding to start the input completion for emoji.

## :ticket: License

[MIT](http://b4b4r07.mit-license.org) © BABAROT (a.k.a. [b4b4r07](https://github.com/b4b4r07))
