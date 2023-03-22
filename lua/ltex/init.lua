local lsp = require("lspconfig")
local Path = require("plenary.path")
local util = require("ltex.util")

local M = {}

--- Get the dictionary file for a project
-- @param client a neovim lsp client
-- @return a plenary path pointing to the dictionary file
local get_dictionary = function(client)
	local root_dir = Path:new(client.config.root_dir)
	-- TODO make this configurable?
	return root_dir / ".dictionary"
end

--- Change the settings for ltex and notify the server
-- @param client nvim lsp client
-- @param field str
-- @param table table
local update_settings = function(client, field, table)
	local settings = client.config.settings
	settings.ltex = util.update_field(settings.ltex, field, table)
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

	update_settings(client, "dictionary", { ["en-US"] = words })
end

function add_lsp_command(name, func)
	vim.lsp.commands[name] = function(args, ctx)
		local client = vim.lsp.get_client_by_id(ctx.client_id)
		func(client, args)
	end
end

function M.setup(config)
	-- Patch the on attach function to load the dictionary file after attaching
	config.on_attach = lsp.util.add_hook_after(config.on_attach, load_words)

	lsp.util.on_setup = lsp.util.add_hook_after(lsp.util.on_setup, function(client)
		add_lsp_command("_ltex.addToDictionary", function(client, args)
			local words = args.arguments[1].words
			update_settings(client, "dictionary", words)
			write_words(client, words["en-US"])
		end)

		add_lsp_command("_ltex.disableRules", function(client, args)
			local rules = args.arguments[1].ruleIds
			update_settings(client, "disabledRules", rules)
		end)

		add_lsp_command("_ltex.hideFalsePositives", function(client, args)
			local rules = args.arguments[1].falsePositives
			update_settings(client, "hiddenFalsePositives", rules)
		end)
	end)

	lsp.ltex.setup(config)
end

return M
