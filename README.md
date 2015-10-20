# emoji-cli

`emoji-cli` provides input completion for emoji on the command line with an interactive filter.

## :memo: Description

Emoji (絵文字, Japanese pronunciation: [emodʑi]) are the ideograms or smileys used in Japanese electronic messages and Web pages, that are spreading outside Japan (ref: [Katy Perry - Roar (Lyric Video)](https://www.youtube.com/watch?v=e9SeJIgWRPk)).

Emoji are funny and make us want to use it :blush:. However, it is hard to use it on the command line. This is because the command line don't have input completion for emoji. Therefore, I developed this command line application `emoji-cli` with an interactive filter.

***DEMO:***

![](https://raw.githubusercontent.com/b4b4r07/screenshots/master/emoji-cli/demo.gif)

## :trollface: Features

- :scream:　Emoji on the command line
- :globe_with_meridians: Interactive filter
- :mag_right: Fuzzy search

Unfortunately, this application supports Z shell only now :bow:.

## :mag: Usage

To insert emoji to the command line, type ctrl-s (<kbd>^s</kbd>).

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
$ source ./emoji-cli/emoji-cli.zsh
```

### Dependencies

- `jq`
- an interactive filter (`fzf`, `peco`...)

## :wrench: Setup

### :bookmark_tabs: `EMOJI_CLI_DIST`

It is defaults to `./dist/emoji.json`.

### :globe_with_meridians: `EMOJI_CLI_FILTER`

It is defaults to `fzf:peco:percol:gof`.

### :open_hands: `EMOJI_CLI_KEYBIND`

It is defaults to `^s` (ctrl-s).

## :ticket: License

[MIT](http://b4b4r07.mit-license.org) © BABAROT (a.k.a. [b4b4r07](https://github.com/b4b4r07))