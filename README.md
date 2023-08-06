# KeySeer.nvim

<!-- badges: start -->
[![GitHub license](https://badgen.net/github/license/jokajak/keyseer.nvim)](https://github.com/jokajak/keyseer.nvim/blob/main/LICENSE)
[![main](https://github.com/jokajak/keyseer.nvim/actions/workflows/main.yml/badge.svg?branch=main)](https://github.com/jokajak/keyseer.nvim/actions/workflows/main.yml)
<!-- badges: end -->

A [Neovim][neovim] plugin that renders a keyboard displaying which keys have assigned actions.

<picture>
 <source media="(prefers-color-scheme: dark)" srcset="https://github.com/jokajak/keyseer.nvim/assets/460913/83438d24-2887-44b5-be1a-9400a6a904dd">
 <source media="(prefers-color-scheme: light)" srcset="https://github.com/jokajak/keyseer.nvim/assets/460913/a099c73e-4bc2-4d2c-bbb6-3f0213075139">
 <img alt="main keyseer view showing a keyboard in neovim" src="https://github.com/jokajak/keyseer.nvim/assets/460913/a099c73e-4bc2-4d2c-bbb6-3f0213075139">
</picture>

* Colorscheme: [Tokyonight](https://github.com/folke/tokyonight.nvim)

## ⚡️ Features

* Display which keys have keymaps

## 📋 Installation

There are two branches to install from:

* `main` (default, **recommended**) will have latest development version of plugin. All changes since last stable release should be perceived as being in beta testing phase (meaning they already passed alpha-testing and are moderately settled).
* `stable` will be updated only upon releases with code tested during public beta-testing phase in `main` branch.

Here are code snippets for some common installation methods:

* With [folke/lazy.nvim](https://github.com/folke/lazy.nvim):

| Branch | Code snippet                                         |
|--------|------------------------------------------------------|
| Main   | `{ 'jokajak/keyseer.nvim', version = false },`       |
| Stable | `{ 'jokajak/keyseer.nvim', version = '*' },`         |

* With [wbthomason/packer.nvim](https://github.com/wbthomason/packer.nvim):

| Branch | Code snippet                                         |
|--------|------------------------------------------------------|
| Main   | `use 'jokajak/keyseer.nvim'`                         |
| Stable | `use { 'jokajak/keyseer.nvim', branch = 'stable' }`  |

## 🧰 Commands

|  Command   |      Description      |
|------------|-----------------------|
| `:KeySeer` | Display the keyboard. |

## ⚙ Configuration

<details>
<summary>Click to unfold the full list of options with their default values</summary>

> **Note**: The options are also available in Neovim by calling `:h keyseer.options`

```lua
KeySeer.config = {
  -- Prints useful logs about what event are triggered, and reasons actions are executed.
  debug = false,
  -- Initial neovim mode to display keybindings
  initial_mode = "n",

  -- Boolean to include built in keymaps in display
  include_builtin_keymaps = false,
  -- Boolean to include global keymaps in display
  include_global_keymaps = true,
  -- Boolean to include buffer keymaps in display
  include_buffer_keymaps = true,
  -- TODO: Represent modifier toggling in highlights
  -- Boolean to include modified keys (e.g. <C-x> or <A-y> or C) in display
  include_modified_keypresses = false,
  -- TODO: Support ignoring whichkey conflicts when showing builtin keymaps
  -- Boolean to ignore whichkey keymaps
  ignore_whichkey_conflicts = true,

  -- Configuration for ui:
  -- - `border` defines border (as in `nvim_open_win()`).
  ui = {
    border = "double", -- none, single, double, shadow
    margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
    winblend = 0, -- value between 0-100 0 for fully opaque and 100 for fully transparent
    size = {
      width = 65,
      height = 10,
    },
    icons = {
      keyseer = "",
    },
    show_header = true, -- boolean if the header should be shown
  },

  -- Keyboard options
  keyboard = {
    -- Layout of the keycaps
    ---@type string|Keyboard
    layout = "qwerty",
    keycap_padding = { 0, 1, 0, 1 }, -- padding around keycap labels [top, right, bottom, left]
    -- How much padding to highlight around each keycap
    highlight_padding = { 0, 0, 0, 0 },
    -- override the label used to display some keys.
    key_labels = {
      ["Up"] = "↑",
      ["Down"] = "↓",
      ["Left"] = "←",
      ["Right"] = "→",
      ["<F1>"] = "F1",
      ["<F2>"] = "F2",
      ["<F3>"] = "F3",
      ["<F4>"] = "F4",
      ["<F5>"] = "F5",
      ["<F6>"] = "F6",
      ["<F7>"] = "F7",
      ["<F8>"] = "F8",
      ["<F9>"] = "F9",
      ["<F10>"] = "F10",

      -- For example:
      -- ["<space>"] = "SPC",
      -- ["<cr>"] = "RET",
      -- ["<tab>"] = "TAB",
    },
  },
}
```

</details>

## Planned features

* It would be nice if the location of the keymap definition could be displayed
* It would be nice if the location of the keymap definition could be opened
  * Using `gd` by default

## ⌨ Contributing

PRs and issues are always welcome. Make sure to provide as much context as possible when opening one.

## 🗞 Wiki

You can find guides and showcase of the plugin on [the Wiki](https://github.com/josh/keyseer.nvim/wiki)

## 🎭 Motivations

* WhichKey is super nice for discovering keymaps
* Legend.nvim is super nice for managing keymaps

## Links

[Neovim]: <https://neovim.io/>
