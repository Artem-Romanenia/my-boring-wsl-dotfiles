local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
  suggest_lsp_servers = false,
})

lsp.ensure_installed({
	'gopls',
	'rust_analyzer',
})

lsp.nvim_workspace()

lsp.setup()

vim.api.nvim_create_autocmd('BufWritePre', {
	pattern = '*.go',
	callback = function ()
		vim.lsp.buf.code_action({ context = { only = { 'source.organizeImports' } }, apply = true })
	end
})
