local configs = require 'nvim_lsp/configs'
local util = require 'nvim_lsp/util'

local server_name = "purescriptls"
local bin_name = "purescript-language-server"

local installer = util.npm_installer {
  server_name = server_name;
  packages = { "purescript", "purescript-language-server" };
  binaries = {bin_name, "purs"};
}

configs[server_name] = {
  default_config = util.utf8_config {
    cmd = {"purescript-language-server", "--stdio"};
    filetypes = {"purescript"};
    root_dir = util.root_pattern("spago.dhall", "bower.json");
  };
  on_new_config = function(new_config)
    local install_info = installer.info()
    if install_info.is_installed then
      if type(new_config.cmd) == 'table' then
        new_config.cmd[1] = install_info.binaries[bin_name]
      else
        new_config.cmd = {install_info.binaries[bin_name]}
      end
    end
  end;
  docs = {
    vscode = "nwolverson.ide-purescript";
    description = [[
https://github.com/nwolverson/purescript-language-server
`purescript-language-server` can be installed via `:LspInstall purescriptls` or by yourself with `npm`
```sh
npm install -g purescript-language-server
```
]];
    default_config = {
      root_dir = [[root_pattern("spago.dhall, bower.json")]];
    };
  };
};
configs[server_name].install = installer.install
configs[server_name].install_info = installer.info

-- vim:et ts=2 sw=2
