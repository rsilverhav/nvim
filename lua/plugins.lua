vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
    -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  use {
  "mfussenegger/nvim-dap",
  opt = true,
  module = { "dap" },
  requires = {
    "theHamsta/nvim-dap-virtual-text",
    "rcarriga/nvim-dap-ui",
    "mfussenegger/nvim-dap-python",
    "nvim-telescope/telescope-dap.nvim",
    { "leoluz/nvim-dap-go", module = "dap-go" },
    { "jbyuki/one-small-step-for-vimkind", module = "osv" },
    { "mxsdev/nvim-dap-vscode-js" },
    {
      "microsoft/vscode-js-debug",
      opt = true,
      run = "npm install --legacy-peer-deps && npm run compile",
    },
  },
  config = function()
    require("config.dap").setup()
  end,
  disable = false,
}
end)
