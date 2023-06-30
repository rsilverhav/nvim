call plug#begin('~/.local/share/nvim/plugged')

Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'easymotion/vim-easymotion'
Plug 'tpope/vim-fugitive'
Plug 'scrooloose/nerdtree'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'vim-airline/vim-airline'
Plug 'jparise/vim-graphql'
Plug 'tpope/vim-surround'
Plug 'pantharshit00/vim-prisma'

" Plug 'prettier/vim-prettier', { 'do': 'yarn install --frozen-lockfile --production' }
" Plug 'prettier/vim-prettier', {
"   \ 'do': 'yarn install --frozen-lockfile --production',
"   \ 'for': ['javascript', 'typescript', '', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'svelte', 'yaml', 'html'] }

Plug 'leafOfTree/vim-svelte-plugin'

Plug 'cocopon/iceberg.vim'
Plug 'NLKNguyen/papercolor-theme'

Plug '/Users/robinsilverhav/dev/vim-plugins/vim-spotify-ctrl' 

" DAP
Plug 'mfussenegger/nvim-dap'
Plug 'mxsdev/nvim-dap-vscode-js'
Plug 'microsoft/vscode-js-debug', { 'tag': 'v1.74.1', 'do': 'npm install --legacy-peer-deps && npm run compile' }
Plug 'rcarriga/nvim-dap-ui'
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'theHamsta/nvim-dap-virtual-text'

call plug#end()

"
" Util
"
set number

"
" Autocomplete cmds
"
set wildmode=longest,list,full


"
" Tabs to spaces
"
set tabstop=2
set shiftwidth=2
set expandtab
set smartindent

"
" Splits
"
set splitright

"
"
" Colors
"
colorscheme iceberg
set cursorline

hi CursorLine ctermbg=237
hi Visual ctermbg=239
hi CocErrorHighligh ctermfg=1 ctermbg=203 guifg=#e27878 guibg=#161821
hi CocSearch ctermfg=120

"
" Helper functions
"
function! GetVisual()
  let [line_start, column_start] = getpos("'<")[1:2]
  let [line_end, column_end] = getpos("'>")[1:2]
  let lines = getline(line_start, line_end)
  if len(lines) == 0
    return ''
  endif
  let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
  let lines[0] = lines[0][column_start - 1:]
  return join(lines, "\n")
endfunction

function! Ctrlf(text)
  let query = a:text
  if query == ""
    let query = input('Search: ')
  endif
  if query != ""
    silent execute "grep! -rI --exclude-dir={node_modules,functions/node_modules,build,static,.git,ios,__sapper__} --exclude=stats.json " . shellescape(query) . " ."
    copen
    redraw!
  endif
endfunction

function! FindAndReplace(query)
  let query = input('Search: ', a:query)
  let replace = input('Replace with: ')
  if query != ""
    let cmd = "!grep --exclude-dir=\"node_modules,.git\" -rIl \"" . query . "\" . | xargs sed -i 's/" . query . "/" . replace . "/g'"
    execute cmd
  endif
endfunction

function! SeachMdn(text)
  let query = a:text
  if query == ""
    let query = input('Search MDN: ')
  endif
  silent execute "!/Applications/Google\\\ Chrome.app/Contents/MacOS/Google\\\ Chrome \"https://developer.mozilla.org/en-US/search?q=" . query . "\""
endfunction

function! CreateReactFC()
  let name = expand("%:t:r")
  execute "normal! iimport React from 'react'\n\ninterface Props {}\n\nexport const \<C-r>=name\<CR>: React.FC<Props> = () => {\n return\n}\<Esc>"
endfunction

function! CreateSvelteComp()
  let name = expand("%:t:r")
  execute "normal! i<script lang=\"ts\">\n</script>\n\n<div>\ntest\n</div>\n\n<style>\n</style>\<Esc>"
endfunction


function! CreateCppHeaderSource()
  let src_dir = input("Enter src dir: ", "src")
  let inc_dir = input("Enter inc dir: ", "inc")
  let class_name = input("Enter class name: ")
  let header_guard = toupper(substitute(class_name, '\(\w\)\([A-Z]\)', '\1_\2', 'g')) . "_H"

  execute "vsp " . inc_dir . "/" . class_name . ".h"
  call append(line('^'), ["#ifndef " . header_guard, "#define " . header_guard, "", "class " . class_name . "{", "};", "", "#endif"])
  noautocmd write

  execute "vsp " . src_dir . "/" . class_name . ".cpp"
  call append(line('^'), ["#include \"" . class_name . ".h\""])
  noautocmd write
endfunction

function! OpenTypescriptPlayground()
  vs /Users/robinsilverhav/dev/scripts/ts_testing_ground/index.ts
  nnoremap <buffer> <leader>r :!yarn --cwd /Users/robinsilverhav/dev/scripts/ts_testing_ground start<cr>
endfunction

function! CheckIfCurrentFileInCwd()
  let currentFile = expand("%:p")
  let cwd = getcwd()
  return currentFile =~ cwd && !(expand("%") =~ "NERD_tree_") && !(currentFile =~ "node_modules")
endfunction

function! OpenNerdTree()
  if CheckIfCurrentFileInCwd()
    execute ":NERDTreeFind"
  else
    execute ":NERDTree"
  endif
endfunction

function! StartNerdtreeFollow()
  if !(exists("g:NERDTree") && g:NERDTree.IsOpen())
    call OpenNerdTree()
    wincmd p
  endif
  augroup NerdtreeTracking
  autocmd BufEnter * if CheckIfCurrentFileInCwd() | NERDTreeFind | wincmd p | endif
  augroup END
endfunction

function! StopNerdtreeFollow()
  execute ":NERDTreeClose"
  autocmd! NerdtreeTracking BufEnter *
endfunction


command! Config vsp ~/.config/nvim/init.vim


"
" NERDTree config
"
let NERDTreeChDirMode=2


"
" Airline config
"
" let g:airline_powerline_fonts = 1
let g:airline#parts#ffenc#skip_expected_string='utf-8[unix]'
let g:airline_section_b = ''


"
" Autocmds
"
autocmd FileType nerdtree setlocal nolist
autocmd FileType typescript setlocal completeopt+=menu,preview
autocmd filetype qf wincmd J
autocmd User EasyMotionPromptBegin silent! CocDisable
autocmd User EasyMotionPromptEnd silent! CocEnable


"
" CoC
"
nnoremap <Leader>D :CocList diagnostics<CR>


"
" FZF
"
au WinLeave * if (&ft ==? "fzf") | q | endif

"
" Copy to clipboard
"
set clipboard+=unnamedplus

"
" Svelte
"
let g:vim_svelte_plugin_load_full_syntax = 1
let g:vim_svelte_plugin_use_typescript = 1

"
" Prettier
"
" let g:prettier#autoformat = 1
" let g:prettier#autoformat_require_pragma = 0

"
" Keybinds
"
let mapleader=" "
nnoremap <Leader>r :!./.run.sh %<CR>
nnoremap <silent> <Leader>c :Files<CR>
nnoremap <silent> <Leader>C :CocCommand<CR>
nnoremap <silent> <Leader>o :call CocAction('runCommand', 'editor.action.organizeImport')<CR>
vnoremap <C-f> :call Ctrlf(GetVisual())<CR>
nnoremap <C-f> :call Ctrlf("")<CR>
nnoremap <C-y> :call FindAndReplace("")<CR>
vnoremap <C-y> :call FindAndReplace(GetVisual())<CR>
nnoremap <Leader>* :call Ctrlf(expand("<cword>"))<CR>
map <Leader> <Plug>(easymotion-prefix)
nnoremap <C-t> :tabnew<CR>
nnoremap <C-j> :tabprevious<CR>
nnoremap <C-k> :tabnext<CR>
nnoremap <C-g> :TSTypeDef<CR>
nnoremap <Leader>t :CtrlPTS<CR>
nnoremap <Leader>v :DartFmt -l 120<CR>
nnoremap <Leader>m :call SeachMdn("")<CR>
vnoremap <Leader>m :call SeachMdn(GetVisual())<CR>
nnoremap <Leader>s :SpotifyInit<CR>
nnoremap <Leader>b :Buffers<CR>
nnoremap <Leader>n :call OpenNerdTree()<CR>
nnoremap <Leader>Nn :call StartNerdtreeFollow()<CR>
nnoremap <Leader>Nq :call StopNerdtreeFollow()<CR>
nnoremap <Esc><Esc> :noh<CR>
nnoremap n nzz
nnoremap N Nzz
nnoremap Ö :
vnoremap Ö :
map <Leader>[ :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
      \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
      \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>
tnoremap <Esc> <C-\><C-n>

imap jk <ESC>

"
" Source
"
source ~/.config/nvim/coc.vim
source ~/.config/nvim/spotify.vim
source ~/.config/nvim/dap.vim
