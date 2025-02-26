local util = require 'lspconfig.util'

return {
  default_config = {
    cmd = { 'sourcekit-lsp' },
    filetypes = { 'swift', 'objc', 'objcpp', 'c', 'cpp' },
    root_dir = function(filename, _)
      return util.root_pattern 'buildServer.json'(filename)
        or util.root_pattern('*.xcodeproj', '*.xcworkspace')(filename)
        -- better to keep it at the end, because some modularized apps contain multiple Package.swift files
        or util.root_pattern('compile_commands.json', 'Package.swift')(filename)
        or vim.fs.dirname(vim.fs.find('.git', { path = filename, upward = true })[1])
    end,
    get_language_id = function(_, ftype)
      local t = { objc = 'objective-c', objcpp = 'objective-cpp' }
      return t[ftype] or ftype
    end,
    on_init = function(client)
      client.server_capabilities.diagnosticProvider = {
        interFileDependencies = true,
        workspaceDiagnostics = false,
      }
    end,
    handlers = {
      ['textDocument/publishDiagnostics'] = function() end,
    },
  },
  docs = {
    description = [[
https://github.com/apple/sourcekit-lsp

Language server for Swift and C/C++/Objective-C.
    ]],
  },
}
