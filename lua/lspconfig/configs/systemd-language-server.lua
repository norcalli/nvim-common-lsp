return {
  default_config = {
    cmd = { 'systemd-language-server' },
    filetypes = { 'systemd' },
    root_dir = function(fname)
      return vim.fs.dirname(vim.fs.find('.git', { path = fname, upward = true })[1])
    end,
    single_file_support = true,
  },
  docs = {
    description = [[
https://github.com/psacawa/systemd-language-server

`systemd-language-server` can be installed via `pip`:
```sh
pip install systemd-language-server
```

Language Server for Systemd unit files
]],
  },
}
