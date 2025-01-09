local util = require 'lspconfig.util'

return {
  default_config = {
    cmd = { 'bqls' },
    filetypes = { 'sql' },
    root_dir = util.find_git_ancestor,
    single_file_support = true,
    settings = {},
  },
  docs = {
    description = [[
https://github.com/kitagry/bqls

The `bqls` BigQuery language server can be installed by running:

```sh
$ go install github.com/kitagry/bqls@latest
```
    ]],
  },
}
