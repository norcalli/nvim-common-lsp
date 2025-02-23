local util = require 'lspconfig.util'

return {
  default_config = {
    cmd = { 'java', '-jar', 'pkl-lsp.jar' },
    filetypes = { 'pkl' },
    root_dir = util.root_pattern('.git'),
    single_file_support = true,
  },
  docs = {
    description = [[
https://github.com/apple/pkl-lsp.git

Retrieve or build the `pkl-lsp` jar from the Git repo. You can then configure `pkl-lsp` like so:

```lua
require('lspconfig').pkl_lsp.setup{
    cmd = { 'java', '-jar', '/path/to/pkl-lsp.jar' },
}
```
    ]],
  },
}
