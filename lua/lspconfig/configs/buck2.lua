return {
  default_config = {
    cmd = { 'buck2', 'lsp' },
    filetypes = { 'bzl' },
    root_dir = function(fname)
      return vim.fs.dirname(vim.fs.find({ '.buckconfig' }, { path = fname, upward = true })[1])
    end,
  },
  docs = {
    description = [=[
https://github.com/facebook/buck2

Build system, successor to Buck

To better detect Buck2 project files, the following can be added:

```
vim.cmd [[ autocmd BufRead,BufNewFile *.bxl,BUCK,TARGETS set filetype=bzl ]]
```
]=],
  },
}
