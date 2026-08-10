local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("lazy").setup({
	spec = {
		--{ import = "plugins" },
		{ "j-hui/fidget.nvim" },
		{
			"nvim-telescope/telescope.nvim",
			version = "*",
			dependencies = {
				"nvim-lua/plenary.nvim",
				{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			},
		},

		{
			"nvim-lualine/lualine.nvim",
			dependencies = { "nvim-tree/nvim-web-devicons" },
		},
		{ "stevearc/conform.nvim" },
		{ "neovim/nvim-lspconfig" },
		{
			"vim-treesitter/nvim-treesitter",
			lazy = false,
			build = ":TSUpdate",
		},
		{
			"saghen/blink.cmp",
			dependencies = {
				"saghen/blink.lib",
				"rafamadriz/friendly-snippets",
			},
			build = function()
				require("blink.cmp").build():pwait()
			end,
			opts = {
				keymap = { preset = "default" },
				completion = { documentation = { auto_show = false } },
				sources = { default = { "lsp", "path", "snippets", "buffer" } },
				fuzzy = { implementation = "rust" },
			},
		},
		{ "lewis6991/gitsigns.nvim" },
		{ "catppuccin/nvim", name = "catppuccin", priority = 1000 },
		{
			"xvzc/chezmoi.nvim",
			dependencies = { "nvim-lua/plenary.nvim" },
			config = function()
				require("chezmoi").setup({})
			end,
		},
		{
			"akinsho/bufferline.nvim",
			dependencies = { "nvim-tree/nvim-web-devicons" },
		},
		{
			"folke/flash.nvim",
			event = "VeryLazy",
			opts = {},
			keys = {
				{
					"s",
					mode = { "n", "x", "o" },
					function()
						require("flash").jump()
					end,
					desc = "Flash",
				},
				{
					"S",
					mode = { "n", "x", "o" },
					function()
						require("flash").treesitter()
					end,
					desc = "Flash Treesitter",
				},
				{
					"r",
					mode = "o",
					function()
						require("flash").remote()
					end,
					desc = "Remote Flash",
				},
				{
					"R",
					mode = { "o", "x" },
					function()
						require("flash").treesitter_search()
					end,
					desc = "Treesitter Search",
				},
				{
					"<c-s>",
					mode = { "c" },
					function()
						require("flash").toggle()
					end,
					desc = "Toggle Flash Search",
				},
			},
		},
		{
			"folke/which-key.nvim",
			event = "VeryLazy",
			dependencies = { "nvim-tree/nvim-web-devicons" },
			keys = {
				{
					"<leader>?",
					function()
						require("which-key").show({ global = false })
					end,
					desc = "Buffer Local Keymaps (which-key)",
				},
			},
		},
		{ "ngynkvn/gotmpl.nvim", opts = {} },
		{
			"stevearc/oil.nvim",
			dependencies = { "nvim-tree/nvim-web-devicons" },
			lazy = false,
		},
		{ "numToStr/Comment.nvim" },
		{
			"jiaoshijie/undotree",
			keys = {
				{ "<leader>u", "<cmd>lua require('undotree').toggle()<cr>" },
			},
		},
		{
			"windwp/nvim-autopairs",
			event = "InsertEnter",
			config = true,
		},
		{
			"nvimdev/lspsaga.nvim",
			config = function()
				require("lspsaga").setup({})
			end,
			dependencies = {
				"nvim-treesitter/nvim-treesitter",
				"nvim-tree/nvim-web-devicons",
			},
		},
	},
	install = { colorscheme = { "catppuccin-nvim" } },
	checker = { enabled = false },
})

-- settings
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4

-- color scheme
require("catppuccin").setup({
	flavour = "mocha",
})
vim.cmd.colorscheme("catppuccin-nvim")

-- telescope setup
require("telescope").load_extension("fidget")
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
vim.keymap.set("n", "<leader>cz", function()
	require("chezmoi.pick").telescope()
end)

-- misc
require("lualine").setup()
require("gitsigns").setup()
require("bufferline").setup()
require("Comment").setup()
require("undotree").setup()
require("nvim-autopairs").setup({ map_cr = true })

require("oil").setup()
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

-- tree sitter
require("nvim-treesitter").install({
	-- config langs
	"json",
	"jsonc",
	"toml",
	"yaml",
	"kdl",
	"rasi",

	-- misc
	"gotmpl",
	"markdown",
	"dockerfile",
	"vim",

	-- web
	"html",
	"css",

	-- docs
	"vimdoc",
	"luadoc",

	-- programming langs
	"lua",
	"rust",
	"c",
	"cpp",

	-- shell langs
	"bash",
	"zsh",
	"fish",

	-- build systems
	"make",
	"cmake",

	-- git
	"diff",
	"git_config",
	"git_rebase",
	"gitattributes",
	"gitcommit",
	"gitignore",
})

-- formating
require("conform").setup({
	format_on_save = {
		timeout_ms = 500,
		lsp_format = "fallback",
	},
	formatters_by_ft = {
		lua = { "stylua" },
		rust = { "rustfmt", lsp_format = "fallback" },
	},
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = { os.getenv("HOME") .. "/.local/share/chezmoi/*" },
	callback = function(ev)
		local bufnr = ev.buf
		local edit_watch = function()
			require("chezmoi.commands.__edit").watch(bufnr)
		end
		vim.schedule(edit_watch)
	end,
})

-- lsp
vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				library = { vim.env.VIMRUNTIME },
				checkThirdParty = false,
			},
			telemetry = {
				enable = false,
			},
		},
	},
})

vim.lsp.enable("lua_ls")
vim.lsp.enable("rust_analyzer")
vim.lsp.enable("kdl_lsp")
vim.lsp.enable("clangd")
