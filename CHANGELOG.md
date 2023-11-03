# Changelog

## [1.6.0](https://github.com/jokajak/keyseer.nvim/compare/v1.5.1...v1.6.0) (2023-11-03)


### Features

* remove setup requirement ([cf9f8cb](https://github.com/jokajak/keyseer.nvim/commit/cf9f8cbdf1c8b780df8cfaf87c6cf05d99a820a5))

## [1.5.1](https://github.com/jokajak/keyseer.nvim/compare/v1.5.0...v1.5.1) (2023-08-22)


### Bug Fixes

* **keyboard:** Readd button start calculation ([38df463](https://github.com/jokajak/keyseer.nvim/commit/38df463e27a0276d41ab6262f4d38face5b1631b))

## [1.5.0](https://github.com/jokajak/keyseer.nvim/compare/v1.4.0...v1.5.0) (2023-08-22)


### Features

* add kinesis layout ([1d872db](https://github.com/jokajak/keyseer.nvim/commit/1d872db0139ccc143eb0f16373dfde571d44320e))

## [1.4.0](https://github.com/jokajak/keyseer.nvim/compare/v1.3.1...v1.4.0) (2023-08-08)


### Features

* adding qwertz layout ([84e2c08](https://github.com/jokajak/keyseer.nvim/commit/84e2c08f5c0805c9d04380d831d2e944da21fee1))

## [1.3.1](https://github.com/jokajak/keyseer.nvim/compare/v1.3.0...v1.3.1) (2023-08-07)


### Bug Fixes

* fix details when ctrl is pressed ([cc82cff](https://github.com/jokajak/keyseer.nvim/commit/cc82cff77ec089e58655188ad66230461e373e54))
* fix details when shift is held down ([7608c60](https://github.com/jokajak/keyseer.nvim/commit/7608c6051f0ba3f0d5dc8a135f073ae89d2d4003))
* fix support for BS keycode ([49e3ac7](https://github.com/jokajak/keyseer.nvim/commit/49e3ac74c13a1cfdc2955543400d35dc2bedcdb9)), closes [#20](https://github.com/jokajak/keyseer.nvim/issues/20)
* handle missing keycodes better ([6953a55](https://github.com/jokajak/keyseer.nvim/commit/6953a5588a9388243f8547ef90533a9724e4b610))

## [1.3.0](https://github.com/jokajak/keyseer.nvim/compare/v1.2.0...v1.3.0) (2023-08-07)


### Features

* add iso layout ([31876f2](https://github.com/jokajak/keyseer.nvim/commit/31876f2302fd87bb82d5cdd57ecab25742e7a415))

## [1.2.0](https://github.com/jokajak/keyseer.nvim/compare/v1.1.1...v1.2.0) (2023-08-07)


### Features

* show builtin keymaps by default ([f69a1d5](https://github.com/jokajak/keyseer.nvim/commit/f69a1d577dc04f60690a40e27eda474863c62366))


### Bug Fixes

* Add support for S-Up keymaps ([3ccea43](https://github.com/jokajak/keyseer.nvim/commit/3ccea430eebfa153da896ba7afcc999809f9685f))
* fix tab keycode support ([d9e59f9](https://github.com/jokajak/keyseer.nvim/commit/d9e59f92ca382f42b03c63d6dce43d917f314ffb))

## [1.1.1](https://github.com/jokajak/keyseer.nvim/compare/v1.1.0...v1.1.1) (2023-08-06)


### Bug Fixes

* handle CR keypresses ([8ed5d54](https://github.com/jokajak/keyseer.nvim/commit/8ed5d54a98f2f055478c769539a5a2e2726cdf22))

## [1.1.0](https://github.com/jokajak/keyseer.nvim/compare/v1.0.0...v1.1.0) (2023-08-06)


### Features

* allow specifying the mode at the command ([28c5b82](https://github.com/jokajak/keyseer.nvim/commit/28c5b82cafbb65cc880bd0842c1c5718185af31e))
* refactor builtin keymaps ([186e656](https://github.com/jokajak/keyseer.nvim/commit/186e656c9e10344a3b04ea230e2ac0c574a0c5cf))

## 1.0.0 (2023-08-06)


### ⚠ BREAKING CHANGES

* Rename to KeySeer

### Features

* add arrow keys to default layouts ([27b77ae](https://github.com/jokajak/keyseer.nvim/commit/27b77aeb914308b53d4fc21451e45717cb94af04))
* add buffer specific keymaps ([6a18036](https://github.com/jokajak/keyseer.nvim/commit/6a1803681aa14163555ccb9ec9dd23968bc345d0))
* Add colors to keycaps ([b3f7db8](https://github.com/jokajak/keyseer.nvim/commit/b3f7db8b783b7b384ccda9f4140ff3672a54e91e))
* add description to details ([c64b3c9](https://github.com/jokajak/keyseer.nvim/commit/c64b3c9d3c9fd1f82c8cc7cf6de4d7fb58373b5a))
* add details for buttons ([b492d1d](https://github.com/jokajak/keyseer.nvim/commit/b492d1d55214f3c57823b46485ba861b7af0a809))
* add detection of button under cursor ([295ba8b](https://github.com/jokajak/keyseer.nvim/commit/295ba8b8c481e058082a5c6d2a704e16a88f52ed))
* add display module ([8d13461](https://github.com/jokajak/keyseer.nvim/commit/8d134619d4587ac5c61a52152274679785890eeb))
* add doc generation check to CI ([#2](https://github.com/jokajak/keyseer.nvim/issues/2)) ([15d4d14](https://github.com/jokajak/keyseer.nvim/commit/15d4d1462f0bf99349ddd626d8f1a4b1b95f8a14))
* add dvorak layout ([e0b1ca4](https://github.com/jokajak/keyseer.nvim/commit/e0b1ca4a83f20226fa6041f00a422c024e02dfbe))
* add enter/exit functions for panes ([7b10d1b](https://github.com/jokajak/keyseer.nvim/commit/7b10d1b3ac28972232f55fb313dbfff02c1522ec))
* add esc key ([721167b](https://github.com/jokajak/keyseer.nvim/commit/721167b8aff84162d4ac250fdb5d38e2b63c22fc))
* add function key support ([ec33131](https://github.com/jokajak/keyseer.nvim/commit/ec33131747ae9a28ffadf96d35083736f776c478))
* add highlighting of pressed modifiers ([eee9ed7](https://github.com/jokajak/keyseer.nvim/commit/eee9ed7b449e7f8198377bec7c1f097c79b30090))
* add keymap navigation ([ec2ac37](https://github.com/jokajak/keyseer.nvim/commit/ec2ac379462b8446660c92a2a5bf30e44a2c0f9d))
* add release script ([144c732](https://github.com/jokajak/keyseer.nvim/commit/144c732b598c01c52f81d89f085ff5a5aefe1a1f))
* add setup script ([#1](https://github.com/jokajak/keyseer.nvim/issues/1)) ([fbffb71](https://github.com/jokajak/keyseer.nvim/commit/fbffb71deea4fafb4e76c5901fa263b155ab8e94))
* add support for modifier keys ([376c8d0](https://github.com/jokajak/keyseer.nvim/commit/376c8d028719258a94ead4a61e04bc019614e2c4))
* allow filtering keymaps displayed ([1960571](https://github.com/jokajak/keyseer.nvim/commit/1960571833573260f4759df4d785e24e24b39516))
* **cd:** add release action ([#4](https://github.com/jokajak/keyseer.nvim/issues/4)) ([85cb257](https://github.com/jokajak/keyseer.nvim/commit/85cb257bfe0c2770364541044cfc478cecf58a2a))
* **cd:** remove homemade release script ([#6](https://github.com/jokajak/keyseer.nvim/issues/6)) ([316de3d](https://github.com/jokajak/keyseer.nvim/commit/316de3d10be0f704bdfecde3d889efe9c2e57570))
* change colors and filter keycaps by modifiers ([7300c4b](https://github.com/jokajak/keyseer.nvim/commit/7300c4b2934a26de0d6900a8767aa3833bafb03b))
* **details:** Add what button is under the cursor ([bcfd117](https://github.com/jokajak/keyseer.nvim/commit/bcfd1179ef807431753b05d6158a804b1123ab73))
* **display:** Add keybindings ([cf18e7a](https://github.com/jokajak/keyseer.nvim/commit/cf18e7a142049d1623a386da87b489e4e3967f9b))
* **keyboard:** Add keyboard class ([9872a49](https://github.com/jokajak/keyseer.nvim/commit/9872a49b92f82dc3f7592890d5999426602aacc8))
* make setup.sh more reliable ([6c2f360](https://github.com/jokajak/keyseer.nvim/commit/6c2f360be9acd1c747f9cce112c6a0205e76532c))
* Rename to KeySeer ([63b34d2](https://github.com/jokajak/keyseer.nvim/commit/63b34d22fb54a29b0598ecb4ff98f3fb93d5a6cf))
* template cleanup and improvements ([#11](https://github.com/jokajak/keyseer.nvim/issues/11)) ([af2fcb0](https://github.com/jokajak/keyseer.nvim/commit/af2fcb0ffcac54eb9e4092bb860c22e29d2579dc))
* toggle shifted keycaps ([3f34d9b](https://github.com/jokajak/keyseer.nvim/commit/3f34d9bb0189c74e17c358909135f2f6522ecd4e))
* **ui:** highlight keycaps ([8d35645](https://github.com/jokajak/keyseer.nvim/commit/8d35645b836eb7721647e9af7bf58aa0d6641442))


### Bug Fixes

* CI diff documentation ([#9](https://github.com/jokajak/keyseer.nvim/issues/9)) ([c4b9836](https://github.com/jokajak/keyseer.nvim/commit/c4b98367f82a6fe47d7268ac7a3887643831eac8))
* easier replace ([0d686ea](https://github.com/jokajak/keyseer.nvim/commit/0d686eab4a45c4437bfaa3fdf8365de305587dff))
* missing README.md mention ([97b16e0](https://github.com/jokajak/keyseer.nvim/commit/97b16e028283cc7a47421da518cd51c3db206427))
* missing steps in README.md ([6ac7c6f](https://github.com/jokajak/keyseer.nvim/commit/6ac7c6fab61fd9af968ad476161b06406692ca87))
* test helpers ([d65dd73](https://github.com/jokajak/keyseer.nvim/commit/d65dd73119ec466bdd99d9833f27c4f6a936fe1e))
