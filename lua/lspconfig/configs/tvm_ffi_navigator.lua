return {
  default_config = {
    cmd = { 'python', '-m', 'ffi_navigator.langserver' },
    filetypes = { 'python', 'cpp' },
    root_dir = function(fname)
      return vim.fs.dirname(vim.fs.find({ 'pyproject.toml', '.git' }, { path = fname, upward = true })[1])
    end,
  },
  docs = {
    description = [[
https://github.com/tqchen/ffi-navigator

The Language Server for FFI calls in TVM to be able jump between python and C++

FFI navigator can be installed with `pip install ffi-navigator`, buf for more details, please see
https://github.com/tqchen/ffi-navigator?tab=readme-ov-file#installation
]],
  },
}
