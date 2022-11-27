# keyfinder.nvim

[![Integration][integration-badge]][integration-runs]

A Neovim plugin written in [Lua][lua] that renders a keyboard displaying which
keys have assigned actions.

![keyfinder light example](https://user-images.githubusercontent.com/460913/204164433-e320d74f-d63c-4130-b397-87dc3c5f1bd1.png#gh-light-mode-only)
![keyfinder dark example](https://user-images.githubusercontent.com/460913/204164495-7d749ccf-4b6f-4992-a2a4-310a65fa4e6e.png#gh-dark-mode-only)

* Colorscheme: [Tokyonight](https://github.com/folke/tokyonight.nvim)

## ✨ Features

- opens a popup with keyboard layout displayed and annotated
- works correctly with built-in key bindings
- works correctly with buffer-local mappings

## ⚡️ Requirements

- Neovim >= 0.7.0

## 📦 Installation

Install the plugin with your preferred package manager:

### [packer](https://github.com/wbthomason/packer.nvim)

```lua
-- Lua
use {
  "jokajak/keyfinder.nvim",
  config = function()
    require("keyfinder").setup {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    }
  end
}
```

## ⚙️ Configuration

Keyfinder comes with the following defaults:

```lua
{
  key_labels = {
    -- override the label used to display some keys. It doesn't effect KM in any other way.
    -- For example:
    -- ["<space>"] = "SPC",
    -- ["<cr>"] = "RET",
    -- ["<tab>"] = "TAB",
    padding = { 0, 1, 0, 1 }, -- padding around keycap labels [top, right, bottom, left]
    highlight_padding = { 0, 0, 0, 0 }, -- how much of the label to highlight
  },
  window = {
    border = "double", -- none, single, double, shadow
    margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
    winblend = 0, -- value between 0-100 0 for fully opaque and 100 for fully transparent
    rows = 5,
    columns = 80,
    show_title = true,
    header_sym = "━",
    header_lines = 2,
    title = "keyfinder.nvim",
    show_legend = true,
  },
  -- disable the Keyfinder popup for certain buf types and file types.
  disable = {
    buftypes = {},
    filetypes = {},
  },
  layout = "qwerty", -- keycap layout, qwerty or dvorak
}
```

## 🚀 Usage

When the **Keyfinder** popup is open, you can use the following key bindings (they are also displayed at the bottom of the screen):

- hit one of the keys to open a group or execute a key binding
- `<esc>` to cancel and close the popup
- `<bs>` go up one level

Apart from the automatic opening, you can also manually open **Keyfinder** for a certain `prefix`:

```vim
:Keyfinder " show all mappings
:Keyfinder <leader> " show all <leader> mappings
:Keyfinder <leader> v " show all <leader> mappings for VISUAL mode
:Keyfinder '' v " show ALL mappings for VISUAL mode
```

## 🎨 Colors

The table below shows all the highlight groups defined for **Keyfinder** with their default link.

| Highlight Group     | Defaults to | Description                                 |
| ------------------- | ----------- | ------------------------------------------- |
| _Keyfinder_         | Search      | Keys with mappings                          |
| _KeyfinderPrefix_   | IncSearch   | Keys that are prefixes                      |

## Testing

This uses [busted][busted], [luassert][luassert] (both through
[plenary.nvim][plenary]) and [matcher_combinators][matcher_combinators] to
define tests in `test/spec/` directory. These dependencies are required only to
run tests, that's why they are installed as git submodules.

Make sure your shell is in the `./test` directory or, if it is in the root directory,
replace `make` by `make -C ./test` in the commands below.

To init the dependencies run

```bash
$ make prepare
```

To run all tests just execute

```bash
$ make test
```

If you have [entr(1)][entr] installed you may use it to run all tests whenever a
file is changed using:

```bash
$ make watch
```

In both commands you myght specify a single spec to test/watch using:

```bash
$ make test SPEC=spec/my_awesome_plugin/my_cool_module_spec.lua
$ make watch SPEC=spec/my_awesome_plugin/my_cool_module_spec.lua
```

## Github actions

An Action will run all the tests and the linter on every commit on the main
branch and also on Pull Request. Tests will be run using
[stable and nightly][neovim-test-versions] versions of Neovim.

[lua]: https://www.lua.org/
[entr]: https://eradman.com/entrproject/
[luarocks]: https://luarocks.org/
[busted]: https://olivinelabs.com/busted/
[luassert]: https://github.com/Olivine-Labs/luassert
[plenary]: https://github.com/nvim-lua/plenary.nvim
[matcher_combinators]: https://github.com/m00qek/matcher_combinators.lua
[integration-badge]: https://github.com/jokajak/keyfinder.nvim/actions/workflows/integration.yml/badge.svg
[integration-runs]: https://github.com/jokajak/keyfinder.nvim/actions/workflows/integration.yml
[neovim-test-versions]: .github/workflows/integration.yml#L17
[help]: doc/keyfinder.txt
