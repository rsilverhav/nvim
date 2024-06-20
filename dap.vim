"
" Helper functions
"
function! StartDebugging()
  let g:dap_tab_before_debugging = tabpagenr()
  let l:dap_debug_start_file = expand("%")

  execute 'tabnew' l:dap_debug_start_file

  " Open new tab for debugging
  let g:dap_debug_tab = tabpagenr()
  lua require'dap'.continue()
endfunction

function! StopDebugging()
  lua require'dap'.disconnect({ terminateDebuggee = true })
  execute 'tabnext' g:dap_tab_before_debugging
  execute 'tabclose' g:dap_debug_tab
endfunction

"
" DAP
"
lua << EOF
-- DAP
require("dap-vscode-js").setup {
  node_path = "node",
  debugger_path = '/Users/robinsilverhav/.local/share/nvim/plugged/vscode-js-debug',
  -- debugger_cmd = { "js-debug-adapter" },
  adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" }, -- which adapters to register in nvim-dap
}

for _, language in ipairs { "typescript", "javascript" } do
    require("dap").configurations[language] = {
      {
        type = "pwa-node",
        request = "launch",
        name = "Launch file (ts-node)",
        runtimeExecutable = "node",
        runtimeArgs = {
          "./node_modules/ts-node/dist/bin.js",
        },
        program = "${file}",
        cwd = "${workspaceFolder}",
        rootPath = "${workspaceFolder}",
      },
      {
        type = "pwa-node",
        request = "launch",
        name = "Launch file",
        program = "${file}",
        cwd = "${workspaceFolder}",
      },
      {
        type = "pwa-node",
        request = "attach",
        name = "Attach",
        processId = require("dap.utils").pick_process,
        cwd = "${workspaceFolder}",
      },
      {
        type = "pwa-node",
        request = "launch",
        name = "Debug Jest Tests",
        -- trace = true, -- include debugger info
        runtimeExecutable = "node",
        runtimeArgs = {
          "./node_modules/jest/bin/jest.js",
          "--runInBand",
          "--config",
          "jest.config.js"
        },
        rootPath = "${workspaceFolder}",
        cwd = "${workspaceFolder}",
        console = "integratedTerminal",
        internalConsoleOptions = "neverOpen",
      },
      {
        type = "pwa-node",
        request = "launch",
        name = "Debug Jasmine Tests",
        runtimeExecutable = "node",
        runtimeArgs = {
          "node_modules/jasmine-ts/lib/index.js",
          "--config",
          "./jasmine.json",
          "NODE_ENV=test"
        },
        rootPath = "${workspaceFolder}",
        cwd = "${workspaceFolder}",
        console = "integratedTerminal",
        internalConsoleOptions = "neverOpen",
      },
      {
        type = "pwa-node",
        request = "launch",
        name = "Run zendr api dev",
        runtimeExecutable = "node",
        runtimeArgs = {
          "run",
          "dev"
        },
        rootPath = "${workspaceFolder}",
        cwd = "${workspaceFolder}/api",
        console = "integratedTerminal",
        internalConsoleOptions = "neverOpen",
      }
    }
end

vim.fn.sign_define('DapBreakpoint', {text='🛑', texthl='', linehl='', numhl=''})
vim.fn.sign_define('DapStopped', {text='➡️', texthl='', linehl='', numhl=''})
vim.fn.sign_define('DapBreakpointCondition', {text='⛔️', texthl='', linehl='', numhl=''})
vim.fn.sign_define('DapLogPoint', {text='💬', texthl='', linehl='', numhl=''})

-- DAP UI
require("dapui").setup({
  icons = { expanded = "", collapsed = "", current_frame = "" },
  mappings = {
    -- Use a table to apply multiple mappings
    expand = { "<CR>", "<2-LeftMouse>" },
    open = "o",
    remove = "d",
    edit = "e",
    repl = "r",
    toggle = "t",
  },
  -- Use this to override mappings for specific elements
  element_mappings = {
    -- Example:
    -- stacks = {
    --   open = "<CR>",
    --   expand = "o",
    -- }
  },
  -- Expand lines larger than the window
  -- Requires >= 0.7
  expand_lines = vim.fn.has("nvim-0.7") == 1,
  -- Layouts define sections of the screen to place windows.
  -- The position can be "left", "right", "top" or "bottom".
  -- The size specifies the height/width depending on position. It can be an Int
  -- or a Float. Integer specifies height/width directly (i.e. 20 lines/columns) while
  -- Float value specifies percentage (i.e. 0.3 - 30% of available lines/columns)
  -- Elements are the elements shown in the layout (in order).
  -- Layouts are opened in order so that earlier layouts take priority in window sizing.
  layouts = {
    {
      elements = {
      -- Elements can be strings or table with id and size keys.
        { id = "scopes", size = 0.25 },
        "breakpoints",
        "stacks",
        "watches",
      },
      size = 40, -- 40 columns
      position = "left",
    },
    {
      elements = {
        "repl",
        "console",
      },
      size = 0.25, -- 25% of total lines
      position = "bottom",
    },
  },
  controls = {
    -- Requires Neovim nightly (or 0.8 when released)
    enabled = true,
    -- Display controls in this element
    element = "repl",
    icons = {
      pause = "",
      play = "",
      step_into = "",
      step_over = "",
      step_out = "",
      step_back = "",
      run_last = "",
      terminate = "",
    },
  },
  floating = {
    max_height = nil, -- These can be integers or a float between 0 and 1.
    max_width = nil, -- Floats will be treated as percentage of your screen.
    border = "single", -- Border style. Can be "single", "double" or "rounded"
    mappings = {
      close = { "q", "<Esc>" },
    },
  },
  windows = { indent = 1 },
  render = {
    max_type_length = nil, -- Can be integer or nil.
    max_value_lines = 100, -- Can be integer or nil.
  }
})

-- Virtual text with treesitter (not working currently
-- require('nvim-treesitter').setup()
-- require("nvim-dap-virtual-text").setup()


-- DAP Listeners
local dap, dapui = require("dap"), require("dapui")
dap.listeners.after.event_initialized["dapui_config"] = function()
  -- vim.fn.StartDebugging()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  -- vim.fn.StopDebugging()
  -- dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  -- vim.fn.StopDebugging()
  -- dapui.close()
end

EOF

"
" Keybinds
"
nnoremap <silent> <Leader>db <Cmd>lua require('dap').toggle_breakpoint()<CR>
nnoremap <silent> <Leader>dB <Cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>
nnoremap <silent> <Leader>dK <Cmd>lua require('dapui').eval()<CR>
vnoremap <silent> <Leader>dK <Cmd>lua require('dapui').eval()<CR>
nnoremap <silent> <Leader>da <Cmd>lua require('dap').disconnect({ terminateDebuggee = true })<CR>
nnoremap <silent> <Leader>ds :call StartDebugging()<CR>

nnoremap <silent> <F1> <Cmd>lua require'dap'.continue()<CR>
nnoremap <silent> <F2> <Cmd>lua require'dap'.step_over()<CR>
nnoremap <silent> <F3> <Cmd>lua require'dap'.step_into()<CR>
nnoremap <silent> <F4> <Cmd>lua require'dap'.step_out()<CR>
