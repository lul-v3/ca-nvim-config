local lsp_config = {
  on_attach = function(client, bufnr)
    if require("utils").is_plugin_installed("lsp_signature.nvim") then
      require("lsp_signature").on_attach({
        hint_prefix = "",
      })
    end

    -- If there is a code formatter installed with null-ls
    -- use that as default formatter.
    local formatters = require("plugins.lsp.utils")
    local client_filetypes = client.config.filetypes or {}
    for _, filetype in ipairs(client_filetypes) do
      if #vim.tbl_keys(formatters.list_registered_formatters(filetype)) > 0 then
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
      end
    end

  end,
}

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
  virtual_text = false,
})

if require("utils").is_plugin_installed("cmp-nvim-lsp") then
  lsp_config["capabilities"] = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
end

local present, mason_lspconfig = pcall(require, "plugins.mason_lspconfig")
if present then
  -- Nur clangd mit speziellen Optionen konfigurieren
  require("lspconfig").clangd.setup({
    on_attach = lsp_config.on_attach,
    capabilities = lsp_config.capabilities,
    cmd = {
      "clangd",
      "--background-index",
      "--clang-tidy",
      "--header-insertion=iwyu",
      "--compile-commands-dir=build",
      "--query-driver=/usr/bin/gcc,/usr/bin/g++,/usr/bin/clang,/usr/bin/clang++",
    },
  })

  -- Alle anderen Server mit Standardkonfiguration
  for _, server in pairs(mason_lspconfig.get_installed_servers()) do
    if server ~= "clangd" then
      require("lspconfig")[server].setup(lsp_config)
    end
  end
end

-- ENTFERNE DIESEN KOMPLETTEN BLOCK!
-- Der folgende Code verursacht die doppelte Konfiguration:
-- local present, mason_lspconfig = pcall(require, "plugins.mason_lspconfig")
-- if present then
--   for _, server in pairs(mason_lspconfig.get_installed_servers()) do
--     require("lspconfig")[server].setup(lsp_config)
--   end
-- end

if require("user_settings").config.lsp ~= nil then
  require("user_settings").config.lsp()
end
