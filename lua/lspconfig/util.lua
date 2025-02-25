local validate = vim.validate
local api = vim.api
local lsp = vim.lsp
local nvim_eleven = vim.fn.has 'nvim-0.11' == 1

local iswin = vim.loop.os_uname().version:match 'Windows'

local M = { path = {} }

M.default_config = {
  log_level = lsp.protocol.MessageType.Warning,
  message_level = lsp.protocol.MessageType.Warning,
  settings = vim.empty_dict(),
  init_options = vim.empty_dict(),
  handlers = {},
  autostart = true,
  capabilities = lsp.protocol.make_client_capabilities(),
}

-- global on_setup hook
M.on_setup = nil

--- @param bufname string
--- @return boolean
function M.bufname_valid(bufname)
  return (bufname:find '^/' or bufname:find '^%a:' or bufname:find '^zipfile://' or bufname:find '^tarfile:') ~= nil
end

--- @param bufnr integer
--- @return integer
function M.validate_bufnr(bufnr)
  if nvim_eleven then
    validate('bufnr', bufnr, 'number')
  end

  return bufnr == 0 and api.nvim_get_current_buf() or bufnr
end

function M.add_hook_before(func, new_fn)
  if func then
    return function(...)
      -- TODO which result?
      new_fn(...)
      return func(...)
    end
  else
    return new_fn
  end
end

function M.add_hook_after(func, new_fn)
  if func then
    return function(...)
      -- TODO which result?
      func(...)
      return new_fn(...)
    end
  else
    return new_fn
  end
end

-- Maps lspconfig-style command options to nvim_create_user_command (i.e. |command-attributes|) option names.
local opts_aliases = {
  ['description'] = 'desc',
}

--- @param command_definition table<string | integer, any>
function M._parse_user_command_options(command_definition)
  --- @type table<string, string | boolean | number>
  local opts = {}

  for k, v in pairs(command_definition) do
    if type(k) == 'string' then
      local attribute = k.gsub(k, '^%-+', '')
      opts[opts_aliases[attribute] or attribute] = v
    elseif type(k) == 'number' and type(v) == 'string' and v:match '^%-' then
      -- Splits strings like "-nargs=* -complete=customlist,v:lua.something"
      -- into { "-nargs=*", "-complete=customlist,v:lua.something" }.
      for _, command_attribute in ipairs(vim.split(v, '%s')) do
        -- Splits attribute into a key-value pair, like "-nargs=*" to { "-nargs", "*" }.
        local attribute, value = unpack(vim.split(command_attribute, '=', { plain = true }))
        attribute = attribute.gsub(attribute, '^%-+', '')
        opts[opts_aliases[attribute] or attribute] = value or true
      end
    end
  end
  return opts
end

function M.create_module_commands(module_name, commands)
  for command_name, def in pairs(commands) do
    if type(def) ~= 'function' then
      local opts = M._parse_user_command_options(def)

      api.nvim_create_user_command(command_name, function(info)
        require('lspconfig')[module_name].commands[command_name][1](unpack(info.fargs))
      end, opts)
    end
  end
end

--- @param startpath string
--- @param cb fun(path: string): boolean?
--- @return string?
function M.search_ancestors(startpath, cb)
  if nvim_eleven then
    validate('func', cb, 'function')
  end
  if cb(startpath) then
    return startpath
  end

  local guard = 100
  for path in vim.fs.parents(startpath) do
    if cb(path) then
      return path
    end

    -- Prevent infinite recursion if our algorithm breaks
    guard = guard - 1
    if guard == 0 then
      return
    end
  end
end

--- @param path string
--- @return string
local function escape_wildcards(path)
  return (path:gsub('[%[%]%?%*]', '\\%0'))
end

--- @return fun(startpath: string): string?
function M.root_pattern(...)
  local patterns = M.tbl_flatten { ... }

  return function(startpath)
    return M.search_ancestors(M.strip_archive_subpath(startpath), function(path)
      for _, pattern in ipairs(patterns) do
        -- NOTE: `glob()` only returns results for paths that exist.
        -- The last `true` arg below means don't resolve/check symlink targets (e.g. allow "broken" symlinks).
        if #vim.fn.glob(escape_wildcards(path) .. '/' .. pattern, true, true, true) > 0 then
          return true
        end
      end
    end)
  end
end

function M.insert_package_json(config_files, field, fname)
  local path = vim.fn.fnamemodify(fname, ':h')
  local root_with_package = vim.fs.dirname(vim.fs.find('package.json', { path = path, upward = true })[1])

  if root_with_package then
    -- only add package.json if it contains field parameter
    local path_sep = iswin and '\\' or '/'
    for line in io.lines(root_with_package .. path_sep .. 'package.json') do
      if line:find(field) then
        config_files[#config_files + 1] = 'package.json'
        break
      end
    end
  end

  return config_files
end

--- @param filetype string
function M.get_active_clients_list_by_ft(filetype)
  local clients = M.get_lsp_clients()
  local clients_list = {}

  for _, client in pairs(clients) do
    --- @diagnostic disable-next-line:undefined-field
    local filetypes = client.config.filetypes or {}
    for _, ft in pairs(filetypes) do
      if ft == filetype then
        table.insert(clients_list, client.name)
      end
    end
  end

  return clients_list
end

--- @param filetype string
function M.get_other_matching_providers(filetype)
  local configs = require 'lspconfig.configs'
  local active_clients_list = M.get_active_clients_list_by_ft(filetype)
  local other_matching_configs = {}

  for _, config in pairs(configs) do
    if not vim.tbl_contains(active_clients_list, config.name) then
      local filetypes = config.filetypes or {}

      for _, ft in pairs(filetypes) do
        if ft == filetype then
          table.insert(other_matching_configs, config)
        end
      end
    end
  end

  return other_matching_configs
end

--- @param filetype string
function M.get_config_by_ft(filetype)
  local configs = require 'lspconfig.configs'
  local matching_configs = {}

  for _, config in pairs(configs) do
    local filetypes = config.filetypes or {}

    for _, ft in pairs(filetypes) do
      if ft == filetype then
        table.insert(matching_configs, config)
      end
    end
  end

  return matching_configs
end

function M.get_active_client_by_name(bufnr, servername)
  -- TODO(glepnir): remove this for loop when we want only support 0.10+
  for _, client in pairs(M.get_lsp_clients { bufnr = bufnr }) do
    if client.name == servername then
      return client
    end
  end
end

function M.get_managed_clients()
  local configs = require 'lspconfig.configs'
  local clients = {}
  for _, config in pairs(configs) do
    if config.manager then
      vim.list_extend(clients, config.manager:clients())
    end
  end

  return clients
end

--- @deprecated use `vim.lsp.config` in Nvim 0.11+ instead.
function M.available_servers()
  local servers = {}
  local configs = require 'lspconfig.configs'
  for server, config in pairs(configs) do
    if config.manager ~= nil then
      table.insert(servers, server)
    end
  end

  return servers
end

--- For zipfile: or tarfile: virtual paths, returns the path to the archive.
--- Other paths are returned unaltered.
--- @param path string
--- @return string
function M.strip_archive_subpath(path)
  -- TODO: is [^\\] necessary? is it meant to exclude a path separator (and only on windows?)?
  return path:match('^%s*zipfile://(.-)::[^\\]') or path:match('^%s*tarfile:(.-)::') or path
end

--- Public functions that can be deprecated once minimum required neovim version is high enough.

--- This can be replaced with `vim.fs.relpath` once minimum neovim version is at least 0.11.
--- @param root string
--- @param path string
--- @return boolean
function M.path.is_descendant(root, path)
  if (path or '') == '' then
    return false
  elseif (root or '') == '' then
    return false
  end

  path = vim.loop.fs_realpath(path)
  if not path then
    return false
  end

  return M.search_ancestors(path, function(dir)
    return dir == root
  end) ~= nil
end

--- Helper functions that can be removed once minimum required neovim version is high enough

function M.tbl_flatten(t)
  --- @diagnostic disable-next-line:deprecated
  return nvim_eleven and vim.iter(t):flatten(math.huge):totable() or vim.tbl_flatten(t)
end

function M.get_lsp_clients(filter)
  --- @diagnostic disable-next-line:deprecated
  return nvim_eleven and lsp.get_clients(filter) or lsp.get_active_clients(filter)
end

--- Deprecated functions

--- @deprecated use `vim.fn.isdirectory(path) == 1` instead
--- @param filename string
--- @return boolean
function M.path.is_dir(filename)
  return vim.fn.isdirectory(filename) == 1
end

--- @deprecated use `(vim.loop.fs_stat(path) or {}).type == 'file'` instead
--- @param path string
--- @return boolean
function M.path.is_file(path)
  return (vim.loop.fs_stat(path) or {}).type == 'file'
end

--- @deprecated use `vim.fs.dirname` instead
M.path.dirname = vim.fs.dirname

--- @deprecated use `vim.fs.normalize` instead
M.path.sanitize = vim.fs.normalize

--- @deprecated use `vim.loop.fs_stat` instead
--- @param filename string
--- @return string|false
function M.path.exists(filename)
  local stat = vim.loop.fs_stat(filename)
  return stat and stat.type or false
end

--- @deprecated use `table.concat({"path1", "path2"})` or regular string concatenation instead
function M.path.join(...)
  return table.concat({ ... }, '/')
end

--- @deprecated use `vim.fn.has('win32') == 1 and ';' or ':'` instead
M.path.path_separator = vim.fn.has('win32') == 1 and ';' or ':'

--- @deprecated use `vim.fs.parents(path)` instead
M.path.iterate_parents = vim.fs.parents

--- @deprecated use `vim.fs.dirname(vim.fs.find('.hg', { path = startpath, upward = true })[1])` instead
function M.find_mercurial_ancestor(startpath)
  return vim.fs.dirname(vim.fs.find('.hg', { path = startpath, upward = true })[1])
end

--- @deprecated use `vim.fs.dirname(vim.fs.find('node_modules', { path = startpath, upward = true })[1])` instead
function M.find_node_modules_ancestor(startpath)
  return vim.fs.dirname(vim.fs.find('node_modules', { path = startpath, upward = true })[1])
end

--- @deprecated use `vim.fs.dirname(vim.fs.find('package.json', { path = startpath, upward = true })[1])` instead
function M.find_package_json_ancestor(startpath)
  return vim.fs.dirname(vim.fs.find('package.json', { path = startpath, upward = true })[1])
end

--- @deprecated use `vim.fs.dirname(vim.fs.find('.git', { path = startpath, upward = true })[1])` instead
function M.find_git_ancestor(startpath)
  return vim.fs.dirname(vim.fs.find('.git', { path = startpath, upward = true })[1])
end

return M
