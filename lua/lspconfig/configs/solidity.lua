return {
  default_config = {
    cmd = { 'solidity-ls', '--stdio' },
    filetypes = { 'solidity' },
    root_dir = function(fname)
      return vim.fs.dirname(vim.fs.find({ '.git', 'package.json' }, { path = fname, upward = true })[1])
    end,
    settings = { solidity = { includePath = '', remapping = {} } },
  },
  docs = {
    description = [[
https://github.com/qiuxiang/solidity-ls

npm i solidity-ls -g

Make sure that solc is installed and it's the same version of the file.  solc-select is recommended.

Solidity language server is a LSP with autocomplete, go to definition and diagnostics.

If you use brownie, use this root_dir:
root_dir =  function(fname) return vim.fs.dirname(vim.fs.find({'brownie-config.yaml', '.git'}, { path = fname, upward = true })[1])    end

on includePath, you can add an extra path to search for external libs, on remapping you can remap lib <> path, like:

```lua
{ solidity = { includePath = '/Users/your_user/.brownie/packages/', remapping = { ["@OpenZeppelin/"] = 'OpenZeppelin/openzeppelin-contracts@4.6.0/' } } }
```

**For brownie users**
Change the root_dir to:

```lua
root_dir = function(fname)
  return vim.fs.dirname(vim.fs.find({ 'brownie-config.yaml', '.git' }, { path = fname, upward = true })[1])
end
```

The best way of using it is to have a package.json in your project folder with the packages that you will use.
After installing with package.json, just create a `remappings.txt` with:

```
@OpenZeppelin/=node_modules/OpenZeppelin/openzeppelin-contracts@4.6.0/
```

You can omit the node_modules as well.
]],
  },
}
