# Design

This document captures my thoughts and design approaches.

## Modeling

There are different components that need to be modeled:

* key_button: The physical buttons on the keyboard display
* key_cap: The text that shows up on top of a button
* key_codes: The individual inputs that comprise a key_sequence
* key_sequence: The sequence of keys pressed for a mapping

Each model captures different attributes.

* key_sequence
  * key_codes: a table that captures the key_codes that comprise the key_sequence
    * the key_codes is an "array" with each entry being either a string or a table of strings
    * each string is a single key_code
  * keys: a string that captures the key_sequence

* key_code: an individual input such as A or <C> or <M>
  * a key_code can be mapped to a key_cap

* key_cap: the text that is on a key_button
  * a key_cap can be mapped to a key_button
  * a key_cap can be mapped to a key_code

Shifted characters (a vs A) are treated as different key_caps. They are tied to the same key_button via a mapping table.

A Layout consists of key_buttons

The config.layout controls which key_cap is mapped to each button on the layout.

Something is not right, things aren't falling into place elegantly.

Run:

1. Get all keymaps
2. Transform keymaps into new format
3. Filter jk

1. Get the list of matching key mappings
    1. Get the list of key mappings
    2. Filter the key mapping to ensure the prefixes match (i.e. vim.startswith)
2. For each key mapping, get the next key codes
    * the next key codes could be a list of key codes
3. Set the highlight based on the information about the next key code
  * longer mappings means it's a prefix
  * more than one mapping means it's a group
  * could be included with shift
  * could be included with meta
  * could be included with ctr

## 8 Mar 2023 Idea

* Keyfinder the plugin is responsible providing a mechanism to open a keyfinder object
* The keyfinder object is responsible for the core functionality:
    * Manage the buffer
    * Track the state
    * Manage the keymaps for the buffer

## Usability Goals

* The keyboard should display the key buttons
* Key buttons that have a keymap for the button should be highlighted
* Pressing `<S-<leader>>` should toggle whether or not the `Shift` key should be considered down. In other words modifying
  if we check for upper case or lower case for a key button
* Pressing `<C-<leader>>` should toggle whether or not the `Ctrl` key should be considered down. In other words
  modifying if we display buttons.
* Pressing `<M-<leader>>` should toggle whether or not the `Meta` key should be considered down. In other words
  modifying if we display buttons.
* The state of the modifier buttons should be displayed at the bottom of the buffer
* The state of the modifier buttons should default to off
* The Keyfinder plugin will expose an API that will allow specifying the initial state of the modifier buttons.
