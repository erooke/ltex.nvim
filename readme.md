# ltex.nvim

Configuration for [ltex-ls](https://valentjn.github.io/ltex/index.html) and neovim.
A note of warning: this has many [limitations](#limitations) and is subject to
change. Maybe I'll get around to fixing those and making it "stable", who
knows.

## Installation

Install using your favorite package manager. We depend on
[lspconfig](github.com/neovim/nvim-lspconfig) and
[plenary.nvim](github.com/nvim-lua/plenary.nvim). Oh also make sure you have
ltex-ls
[installed](https://github.com/neovim/nvim-lspconfig/blob/fd8f18fe819f1049d00de74817523f4823ba259a/doc/server_configurations.md#ltex).

An example [lazy.nvim](github.com/folke/lazy.nvim) plugin spec looks something
like this:
```lua
{
	"erooke/ltex.nvim",
	dependencies = {
		"neovim/nvim-lspconfig",
		"nvim-lua/plenary.nvim"
	},
}
```

## Configuration

This plugin is a very thin wrapper around `lspconfig`, so thin it doesn't have
its own configuration yet. Replace wherever you would normally call
`require('lspconfig').setup(...)` with `require('ltex').setup(...)` all your
settings will get passed through while patching things to make a dictionary
file work. For example my configuration looks like this:
```lua
ltex.setup({
	settings = {
		ltex = {
			additionalRules = {
				languageModel = "~/.local/share/ngrams/",
			},
			latex = {
				commands = {
					["\\nameref{}"] = "ignore",
					["\\textcite{}"] = "ignore",
					["\\subimport{}{}"] = "ignore",
					["\\import{}{}"] = "ignore",
					["\\texttt{}"] = "ignore",
				},
			},
		},
	},
})
```

## Limitations

- This saves your dictionary to the root of your project with a filename `.dictionary`
- This assumes your language is en-US
- Ignored rules and false positives do not persist across sessions as I'm not sure where to save those


## Prior Art
Other people have done this too. Their setups are probably better, I just
couldn't make em work.

- [ltex-ls.nvim](https://github.com/vigoux/ltex-ls.nvim)
- [ucw.nvim](https://github.com/Aetf/ucw.nvim/blob/main/lua/ucw/lsp/lang/ltex.lua)

