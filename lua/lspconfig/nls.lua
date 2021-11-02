local configs = require 'lspconfig/configs'
local util = require 'lspconfig/util'

configs.nls = {
  default_config = {
    cmd = { 'nls' },
    filetypes = { 'ncl', 'nickel' },
    root_dir = util.find_git_ancestor,
  },

  docs = {
    description = [[
Nickel Language Server

https://github.com/tweag/nickel

`nls` can be installed with nix, or cargo from the Nickel repository.
```sh
git clone https://github.com/tweag/nickel.git
```

Nix:
```sh
cd nickel
nix-env -f . -i
```

cargo:
```sh
cd nickel/lsp/nls
cargo install --path .
```

Install the Nickel vim plugin https://github.com/nickel-lang/vim-nickel.
        ]],
  },
}
