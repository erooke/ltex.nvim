local lsp = require("lspconfig")
local Path = require("plenary.path")

local M = {}

--- Get the dictionary file for a project
-- @param client a neovim lsp client
-- @return a plenary path pointing to the dictionary file
local get_dictionary = function(client)
	local root_dir = Path:new(client.config.root_dir)
	-- TODO make this configurable?
	return root_dir / ".dictionary"
end

--- Add words to a running ltex-ls instance
-- @param client a neovim lsp client
-- @param words a table of words to add
local add_words = function(client, words)
	local settings = client.config.settings
	local dictionary = settings.ltex.dictionary

	if dictionary == nil then
		dictionary = {
			["en-US"] = {},
		}
	end

	for _, word in ipairs(words) do
		table.insert(dictionary["en-US"], word)
	end

	settings.ltex.dictionary = dictionary
	client.notify("workspace/didChangeConfiguration", {
		settings = settings,
	})
end

--- Save words to a dictionary file
-- @param client a neovim lsp client
-- @param words a table of words to save
local write_words = function(client, words)
	local dict_file = get_dictionary(client)

	if not dict_file:is_file() then
		dict_file:touch()
	end

	for _, word in ipairs(words) do
		dict_file:write(word .. "\n", "a")
	end
end

--- Load words from a dictionary file
-- @param client a neovim lsp clien
local load_words = function(client)
	local dictionary_file = get_dictionary(client)

	if not dictionary_file:is_file() then
		return
	end

	local words = dictionary_file:readlines()
	add_words(client, words)
end

function M.setup(config)
	-- Patch the on attach function to load the dictionary file after attaching
	config.on_attach = lsp.util.add_hook_after(config.on_attach, load_words)

	lsp.util.on_setup = lsp.util.add_hook_after(lsp.util.on_setup, function(client)
		vim.lsp.commands["_ltex.addToDictionary"] = function(args, ctx)
			local client = vim.lsp.get_client_by_id(ctx.client_id)
			local words = args.arguments[1].words["en-US"]
			ltex.add_words(client, words)
			ltex.write_words(client, words)
		end
	end)

	lsp.ltex.setup(config)
end

return M
