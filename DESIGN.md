# KeySeer Design

This document captures my design considerations and approaches.

## Keyboard display

I want to display a keyboard with each button highlighted to tell me information about that button.

I want to know if there is an action associated with the button, or if the button is a prefix for multiple actions, or
if there are multiple actions for the button.

I want to know if I need to push shift for the button to be a prefix or an action.

I want to be able to display the keyboard as if I pressed the shift button down.

To model this behavior, I think I should introduce a concept of 'layers'. Each layer of the keyboard represents
different combinations of modifiers:

* Normal
* Ctrl pressed
* Meta pressed
* Shift pressed
* Ctrl + Meta pressed
* Ctrl + Shift pressed
* Shift + Meta pressed
* Ctrl + Shift + Meta pressed

Then I can process the keymaps into each layer for rendering.

Using a data structure that captures every layer state at every button makes it easier to simultaneously traverse all
layers at the same time.

Since I am displaying two different character sets, my keymap tree needs to be traversable using either the shifted
version of the buttons or the unshifted versions of the buttons.

What I really care about is if the key is displayed on the keyboard itself.

## Internal Data structure

I can convert the keymap `lhs` from `<C-g>Gg` to a table of:

```lua
local keypresses = {
  -- this entry captures the information about the keypresses associated with a keycap
  -- this entry is used when displaying the keyboard
  g = {
    keymaps = {},
    modifiers = {
      "Ctrl" = true
    },
    children = {}
  }
  -- this entry captures the actual keypress
  -- this entry is used when updating the keyboard state
  ["<C-g>"] = {
    keymaps = {}
    children = {
      g = {
        keymaps = {},
        modifiers = {
          "Shift" = true
        },
        children = {}
      },
      G = {
        keymaps = {},
        modifiers = {
          "Shift" = true
        },
        children = {
          g = {
            keymaps = {
              [""] = `rhs`
            }
          }
        }
      },
    }
  }
}
```

## User Experience

* `:KeySeer` opens main KeySeer window
  * Can use `KeySeer n` or `KeySeer i` to configure which mode is displayed
* Different views accessible via keymap:
  * H: Main display showing the keyboard layout with highlighting
  * I: Information display showing the details for the current keycap
  * C: Configuration display for changing the mode or meta presses
  * ?: Help screen
* Navigating from the current keypress to the next is accomplished with `g<keypress>`

It would be neat if I could somehow integrate with hydra.nvim
