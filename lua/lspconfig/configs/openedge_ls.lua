local util = require 'lspconfig.util'

return {
  default_config = {
    filetypes = { 'progress' },
    root_dir = util.root_pattern 'openedge-project.json',
    on_new_config = function(config)
      if not config.cmd and config.oe_jar_path then
        config.cmd = {
          'java',
        }
        config.cmd[#config.cmd + 1] = '-jar'
        config.cmd[#config.cmd + 1] = config.oe_jar_path
        if config.debug then
          config.cmd[#config.cmd + 1] = '--debug'
        end
        if config.trace then
          config.cmd[#config.cmd + 1] = '--trace'
        end
      end
    end,
  },
  docs = {
    description = [[
[Language server](https://github.com/vscode-abl/vscode-abl) for Progress OpenEdge ABL.

For manual installation, download abl-lsda.jar from the [VSCode extension](https://github.com/vscode-abl/vscode-abl/releases/latest).

Configuration

```lua
require('lspconfig').openedge_ls.setup {
  oe_jar_path = '/path/to/abl-lsda.jar',
  debug = false, -- Set to true for debug logging
  trace = false, -- Set to true for trace logging (REALLY verbose)
  init_options = {
    abl = {
      configuration = {
        runtimes = {
          { name = '12.8', path = '/opt/progress/dlc' }
        },
        maxThreads = 1
      },
      completion = {
        upperCase = false
      },
      buildMode = 1 -- Build all
    }
  }
}
```
]],
  },
}
