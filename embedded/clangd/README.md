# OpenBMC C++ development in NvChad

This sets up `clangd` for the OpenBMC tree, using the `bmcweb` devtool workspace as
the main target.  All changes live under `~/.config/nvim` and
`~/extraSpace/embedded`; nothing system-wide is installed or changed.

## What changed

### 1. Neovim / NvChad

The only Neovim file that changed is:

```
~/.config/nvim/
├── init.lua
└── lua/
    ├── plugins/init.lua          # already loads nvim-lspconfig
    └── configs/lspconfig.lua     # <-- clangd cmd + --query-driver
```

`lua/plugins/init.lua` already has

```lua
{
  "neovim/nvim-lspconfig",
  config = function()
    require "configs.lspconfig"
  end,
},
```

so no change to `init.lua` is needed.  The `clangd` block now launches:

```
clangd
  --header-insertion=never
  --background-index
  --completion-style=detailed
  --query-driver=/usr/bin/*,<openbmc>/build/*/tmp/work/*/*/*/recipe-sysroot-native/usr/bin/*/*-g++,...-gcc
```

Why:

* `--query-driver` lets clangd ask the **Yocto cross compiler** for its target and
  system include paths (libstdc++, Boost, …).  Without it clangd cannot find
  `cstdint`, `memory`, or `boost/...` for the cross build.
* The `/usr/bin/*` entry is the fallback: when a file has no compilation database,
  clangd queries the host compiler and finds the host Boost under `/usr/include`.
  Verified with `clangd --check` on a file that includes `boost/asio.hpp` and
  `boost/beast.hpp` → 0 errors.
* `--background-index` builds the project index in the background (useful for
  cross-file go-to-definition).
* `--completion-style=detailed` gives richer completion items in nvim-cmp.

### 2. Compilation database publisher

BitBake/Meson writes the database below
`build/<machine>/tmp/work/.../bmcweb-*/compile_commands.json`, which is **not** an
ancestor of `build/<machine>/workspace/sources/bmcweb` (the tree `devtool modify`
gives you).  clangd only searches the file's directory and its parents, so the
database must be published into the source tree.

Files under `~/extraSpace/embedded/clangd/`:

| file | purpose |
| --- | --- |
| `gen_compile_db.py` | selects the usable bmcweb database, makes all paths absolute, and writes it to `.../workspace/sources/bmcweb/compile_commands.json` |
| `refresh.sh` | runs `devtool build <recipe>` and then `gen_compile_db.py` |
| `check_lsp.lua` | headless smoke test (attach, diagnostics, completion, Boost go-to-definition) |

The generator also:

* replaces the bare compiler name (`arm-openbmc-linux-gnueabi-g++`) with its
  absolute path, so clangd does not need the Yocto toolchain on `$PATH`;
* drops the GCC-16 `-fcanon-prefix-map` flag, which clangd 23 reports as
  `Unknown argument` (the BitBake build still uses it);
* adds `/compile_commands.json` to the workspace repository's
  `.git/info/exclude` so it does not show up in `git status`.

## Reproduce it

### 1. Prerequisite

`clangd` must be on `$PATH` (this machine has `/usr/bin/clangd`, version 23.1.4):

```sh
clangd --version
```

### 2. Generate / refresh the compilation database

```sh
cd ~/extraSpace/embedded/openbmc
. setup romulus
devtool build bmcweb
python3 ~/extraSpace/embedded/clangd/gen_compile_db.py
```

Or run both steps with:

```sh
~/extraSpace/embedded/clangd/refresh.sh
```

Expected output:

```
wrote /home/nort/extraSpace/embedded/openbmc/build/romulus/workspace/sources/bmcweb/compile_commands.json
  source database: .../tmp/work/arm1176jzs-openbmc-linux-gnueabi/bmcweb/1.0+git/bmcweb-1.0+git/compile_commands.json
  entries: 34
  compiler: .../recipe-sysroot-native/usr/bin/arm-openbmc-linux-gnueabi/arm-openbmc-linux-gnueabi-g++
```

`devtool build bmcweb` is enough for clangd.  You do **not** need
`devtool ide-sdk` for this workflow.

### 3. Open the sources

```sh
cd ~/extraSpace/embedded/openbmc/build/romulus/workspace/sources/bmcweb
nvim http/mutual_tls.cpp
```

clangd's workspace root becomes the bmcweb source directory, and the generated
`compile_commands.json` is found automatically.

### 4. Verify

Inside Neovim:

```vim
:lua =vim.lsp.get_clients({ name = "clangd" })
:checkhealth vim.lsp
```

Or run the headless smoke test:

```sh
cd ~/extraSpace/embedded/openbmc/build/romulus/workspace/sources/bmcweb
nvim --headless http/mutual_tls.cpp \
  -c "luafile ~/extraSpace/embedded/clangd/check_lsp.lua"
```

Expected:

```
PASS: clangd attached
  root_dir: .../workspace/sources/bmcweb
  diagnostics: 0
PASS: completion works
PASS: go-to-declaration works
PASS: go-to-definition resolves Boost
  file://.../recipe-sysroot/usr/include/boost/asio/ip/address.hpp
PASS: real-time diagnostics
```

### 5. Use it

| key / command | action |
| --- | --- |
| `gd` | go to definition |
| `gD` | go to declaration |
| `K` | hover / documentation |
| `<C-Space>` | trigger completion |
| `<C-n>` / `<C-p>` | next / previous completion item |
| `<CR>` | accept completion |
| `<leader>ds` | diagnostics in location list |
| `:LspClangdSwitchSourceHeader` | switch between `.cpp` / `.hpp` |

C++ syntax highlighting comes from Vim's `cpp` syntax + NvChad's base46 theme
(`:set syntax?` → `cpp`).  NvChad deliberately disables LSP semantic tokens to
avoid double-highlighting; clangd still provides diagnostics, completion and
navigation.

## Refreshing after code changes

Run `refresh.sh` again after:

* editing `meson.build` or adding/removing source files (Meson regenerates the
  database during `devtool build`);
* pulling OpenBMC or changing recipes;
* switching build directories.

For another devtool workspace recipe:

```sh
~/extraSpace/embedded/clangd/refresh.sh phosphor-logging
```

This publishes the database into that recipe's
`build/<machine>/workspace/sources/<recipe>` directory.

If you use another machine directory:

```sh
OPENBMC_MACHINE=romulus ~/extraSpace/embedded/clangd/refresh.sh
```

## About the `devtool ide-sdk` errors

`devtool ide-sdk -i none bmcweb obmc-phosphor-image` is **not required for
clangd**; the LSP workflow only needs `devtool build bmcweb`.  While testing your
exact command, two independent problems showed up.

### 1. `Nothing RPROVIDES 'bmcweb-ptest'` (fixed locally)

Your `devtool ide-sdk` run failed because it wrote

```
IMAGE_INSTALL:append = " bmcweb-ptest"
```

into `build/romulus/workspace/appends/obmc-phosphor-image.bbappend` even though
the `bmcweb-ptest` package does not exist in this build.

Root cause: `bmcweb` inherits `ptest`, but OE-Core's `ptest.bbclass` only creates
`${PN}-ptest` when `PTEST_ENABLED == "1"`, i.e. when `ptest` is in
`DISTRO_FEATURES`.  OpenBMC's `phosphor-base.inc` overrides
`DISTRO_FEATURES_DEFAULTS` without `ptest`, so there is no `bmcweb-ptest` package.
`ide_sdk.py` added it unconditionally.

Fix applied:

1. `upstream-layers/openembedded-core/scripts/lib/devtool/ide_sdk.py`:

   ```python
   self.has_ptest = (
       bb.data.inherits_class('ptest', recipe_d)
       and recipe_d.getVar('PTEST_ENABLED') == '1')
   ```

2. Removed the generated
   `build/romulus/workspace/appends/obmc-phosphor-image.bbappend` (it contained
   the stale ptest line and, later, the debug-image settings).
   `bitbake -n obmc-phosphor-image` then resolved every task without a missing
   provider.

### 2. `Image size error ... exceeds allowed ...` (after the ptest fix)

With the ptest problem fixed, `ide-sdk` proceeds further and installs
`gdbserver` plus the `IMAGE_GEN_DEBUGFS` / `image-combined-dbg` settings.  On the
32 MiB `romulus` flash layout the squashfs ends up **16 KiB larger** than the
rootfs slot, so `do_generate_static` fails:

```
Image size error: ... is 24395776 bytes, exceeds allowed 24379392 bytes (over by 16384 bytes)
```

This is a build-image size constraint, unrelated to clangd.  Options:

* **Recommended for LSP:** don't pass the image to `ide-sdk`; use
  `devtool build bmcweb` only.  Nothing else is needed.
* If you need `ide-sdk`'s remote-debug setup, you must free at least 16 KiB in
  the image (remove a package) or use a flash layout with more room.  Removing
  `gdbserver` would defeat the purpose.

To leave your tree in a buildable state, the ide-sdk-generated
`build/romulus/workspace/appends/obmc-phosphor-image.bbappend` was removed, so a
plain `bitbake obmc-phosphor-image` builds as before (verified: 6316 tasks, all
succeeded).  Rerunning `ide-sdk` recreates that bbappend.

Caveat: the `ide_sdk.py` change is a local patch to the upstream layer.  If you
update/re-sync `upstream-layers/openembedded-core`, it may be overwritten; re-apply
it or skip `devtool ide-sdk`.  Do **not** add `ptest` to `DISTRO_FEATURES` as a
workaround: that changes the signature of the whole distro and forces a large
rebuild.

## Troubleshooting

* **clangd does not attach** — make sure you opened a `.c`/`.cpp` file after
  startup; check `:lua =vim.lsp.get_clients()`.  NvChad lazy-loads
  `nvim-lspconfig` on `User FilePost`, so this is normally automatic.  In a
  headless test you must emit that event yourself (see `check_lsp.lua`).
* **`'cstdint' file not found` / `'memory' file not found`** — clangd did not
  query the cross compiler.  Regenerate the database and confirm the `compiler:`
  line printed by `gen_compile_db.py` is an absolute Yocto toolchain path.
* **Boost not found** — the recipe sysroot may not be built yet (run
  `devtool build bmcweb`), or the `--query-driver` glob does not match your build
  directory.  The OpenBMC path is hard-coded in
  `~/.config/nvim/lua/configs/lspconfig.lua` as
  `~/extraSpace/embedded/openbmc`; adjust it if you move the checkout.
* **`Unknown argument: '-fcanon-prefix-map'`** — an old generated database; rerun
  `gen_compile_db.py` (it drops that flag).
* **clangd log** — `:lua vim.cmd("edit " .. vim.lsp.get_log_path())`.
