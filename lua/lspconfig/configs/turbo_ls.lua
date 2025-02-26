local util = require 'lspconfig.util'

return {
  default_config = {
    cmd = { 'turbo-language-server', '--stdio' },
    filetypes = { 'html', 'ruby', 'eruby', 'blade', 'php' },
    root_dir = util.root_pattern('Gemfile', '.git'),
  },
  docs = {
    description = [[
https://www.npmjs.com/package/turbo-language-server

`turbo-language-server` can be installed via `npm`:

```sh
npm install -g turbo-language-server
```

or via `yarn`:

```sh
yarn global add turbo-language-server
```
]],
  },
}
