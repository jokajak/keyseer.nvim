# KeySeer.nvim

[![Integration][integration-badge]][integration-runs]

A Neovim plugin written in [Lua][lua] that renders a keyboard displaying which
keys have assigned actions.

![keyseer light example](https://user-images.githubusercontent.com/460913/204164433-e320d74f-d63c-4130-b397-87dc3c5f1bd1.png#gh-light-mode-only)
![keyseer dark example](https://user-images.githubusercontent.com/460913/204164495-7d749ccf-4b6f-4992-a2a4-310a65fa4e6e.png#gh-dark-mode-only)

* Colorscheme: [Tokyonight](https://github.com/folke/tokyonight.nvim)

## ⚡️ Features

* Display which keys have keymaps

## 📋 Installation

There are two branches to install from:

- `main` (default, **recommended**) will have latest development version of plugin. All changes since last stable release should be perceived as being in beta testing phase (meaning they already passed alpha-testing and are moderately settled).
- `stable` will be updated only upon releases with code tested during public beta-testing phase in `main` branch.

Here are code snippets for some common installation methods:

* With [folke/lazy.nvim](https://github.com/folke/lazy.nvim):

| Branch | Code snippet                                         |
|--------|------------------------------------------------------|
| Main   | `{ 'jokajak/keyseer.nvim', version = false },`      |
| Stable | `{ 'jokajak/keyseer.nvim', version = '*' },`        |

* With [wbthomason/packer.nvim](https://github.com/wbthomason/packer.nvim):

| Branch | Code snippet                                         |
|--------|------------------------------------------------------|
| Main   | `use 'jokajak/keyseer.nvim'`                        |
| Stable | `use { 'jokajak/keyseer.nvim', branch = 'stable' }` |

## ☄ Getting started

> Describe how to use the plugin the simplest way

## ⚙ Configuration

<details>
<summary>Click to unfold the full list of options with their default values</summary>

> **Note**: The options are also available in Neovim by calling `:h keyseer.options`

```lua
{
  key_labels = {
    -- override the label used to display some keys.
    -- For example:
    -- ["<space>"] = "SPC",
    -- ["<cr>"] = "RET",
    -- ["<tab>"] = "TAB",
    padding = { 0, 1, 0, 1 }, -- padding around keycap labels [top, right, bottom, left]
    highlight_padding = { 0, 0, 0, 0 }, -- how much of the label to highlight
  },
  -- control how the popup window looks
  window = {
    border = "double", -- none, single, double, shadow
    margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
    winblend = 0, -- value between 0-100 0 for fully opaque and 100 for fully transparent
    rows = 5,
    columns = 80,
    show_title = true, -- whether or not to show the title
    header_sym = "━",
    header_lines = 2,
    title = "KeySeer.nvim",
    show_legend = true,  -- whether or not to show the legend
  },
  -- disable the KeySeer popup for certain buf types and file types.
  disable = {
    buftypes = {},
    filetypes = {},
  },
  layout = "qwerty", -- keycap layout, qwerty or dvorak
}
```

</details>

## 🧰 Commands

|  Command   |      Description      |
|------------|-----------------------|
| `:KeySeer` | Display the keyboard. |

## General Principles

* The keyboard should display information about the current keymaps
* It should be possible to navigate around the keyboard
* It would be nice if more information can be shown about the keymaps on a particular keycap
  * use `K`
* It would be nice if the location of the keymap definition could be displayed
  * As part of `K` display
* It would be nice if the location of the keymap definition could be opened
  * Using `gd` by default
* Keys can be "pressed" by prefixing the keypress with `<leader>`

## ⌨ Contributing

PRs and issues are always welcome. Make sure to provide as much context as possible when opening one.

## 🗞 Wiki

You can find guides and showcase of the plugin on [the Wiki](https://github.com/josh/keyseer.nvim/wiki)

## 🎭 Motivations

* WhichKey is super nice for discovering keymaps
* Legend.nvim is super nice for managing keymaps
