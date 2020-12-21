local configs = require 'lspconfig/configs'
local util = require 'lspconfig/util'

local server_name = "svls"

configs[server_name] = {
  default_config = {
    cmd = { "svls", "--stdio" },
    filetypes = { "verilog", "systemverilog" },
    root_dir = util.path.dirname;
  };
  docs = {
    description = [[
      https://github.com/dalance/svls
      Language server for verilog and SystemVerilog
    ]];
  }
}
-- vim:et ts=2 sw=2
