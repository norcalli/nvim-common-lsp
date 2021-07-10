local configs = require "lspconfig/configs"
local util = require "lspconfig/util"

local server_name = "ember"
local bin_name = "ember-language-server"

configs[server_name] = {
  default_config = {
    cmd = { bin_name, "--stdio" },
    filetypes = { "handlebars", "typescript", "javascript" },
    root_dir = function(fname)
      return util.root_pattern("ember-cli-build.js", ".git")(fname) or util.path.dirname(fname)
    end,
  },
  docs = {
    description = [[
https://github.com/lifeart/ember-language-server

`ember-language-server` can be installed via `npm`:

```sh
npm install -g @lifeart/ember-language-server
```
]],
  },
}

-- vim:et ts=2 sw=2
