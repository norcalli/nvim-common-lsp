return {
  default_config = {
    cmd = { 'fsautocomplete', '--adaptive-lsp-server-enabled' },
    root_dir = function(fname)
      return vim.fs.dirname(vim.fs.find({ '*.sln', '*.fsproj', '.git' }, { path = fname, upward = true })[1])
    end,
    filetypes = { 'fsharp' },
    init_options = {
      AutomaticWorkspaceInit = true,
    },
    -- this recommended settings values taken from  https://github.com/ionide/FsAutoComplete?tab=readme-ov-file#settings
    settings = {
      FSharp = {
        keywordsAutocomplete = true,
        ExternalAutocomplete = false,
        Linter = true,
        UnionCaseStubGeneration = true,
        UnionCaseStubGenerationBody = 'failwith "Not Implemented"',
        RecordStubGeneration = true,
        RecordStubGenerationBody = 'failwith "Not Implemented"',
        InterfaceStubGeneration = true,
        InterfaceStubGenerationObjectIdentifier = 'this',
        InterfaceStubGenerationMethodBody = 'failwith "Not Implemented"',
        UnusedOpensAnalyzer = true,
        UnusedDeclarationsAnalyzer = true,
        UseSdkScripts = true,
        SimplifyNameAnalyzer = true,
        ResolveNamespaces = true,
        EnableReferenceCodeLens = true,
      },
    },
  },
  docs = {
    description = [[
https://github.com/fsharp/FsAutoComplete

Language Server for F# provided by FsAutoComplete (FSAC).

FsAutoComplete requires the [dotnet-sdk](https://dotnet.microsoft.com/download) to be installed.

The preferred way to install FsAutoComplete is with `dotnet tool install --global fsautocomplete`.

Instructions to compile from source are found on the main [repository](https://github.com/fsharp/FsAutoComplete).

You may also need to configure the filetype as Vim defaults to Forth for `*.fs` files:

`autocmd BufNewFile,BufRead *.fs,*.fsx,*.fsi set filetype=fsharp`

This is automatically done by plugins such as [PhilT/vim-fsharp](https://github.com/PhilT/vim-fsharp), [fsharp/vim-fsharp](https://github.com/fsharp/vim-fsharp), and [adelarsq/neofsharp.vim](https://github.com/adelarsq/neofsharp.vim).

    ]],
  },
}
