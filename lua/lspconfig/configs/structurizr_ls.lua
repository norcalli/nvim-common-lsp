local util = require 'lspconfig.util'

return {
  default_config = {
    cmd = { 'structurizr-lsp' },
    filetypes = { 'structurizr' },
    root_dir = util.root_pattern('.dsl', '.git'),
  },
  docs = {
    description = [[
    https://github.com/tacsiazuma/structurizr-lsp
    Language server for the Structurizr DSL (https://structurizr.com/dsl) written in Go.
  ]],
  },
}
