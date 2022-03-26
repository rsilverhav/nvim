call plug#begin('~/.local/share/nvim/plugged')

Plug 'HerringtonDarkholme/yats.vim'
Plug 'mxw/vim-jsx'
Plug 'pangloss/vim-javascript'
Plug 'leafgarland/typescript-vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'easymotion/vim-easymotion'
Plug 'tpope/vim-fugitive'
Plug 'scrooloose/nerdtree'
"Plug 'ctrlpvim/ctrlp.vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'vim-airline/vim-airline'
Plug 'w0rp/ale'
Plug 'dart-lang/dart-vim-plugin'
Plug 'jparise/vim-graphql'

Plug 'leafOfTree/vim-svelte-plugin'

Plug 'cocopon/iceberg.vim'
Plug 'NLKNguyen/papercolor-theme'

call plug#end()

"
" Memory
"
set mmp=5000


"
" Util
"
set mouse=a
set number
set backspace=indent,eol,start
set list
set hlsearch

"
"
" File tab completion
"
set wildmode=longest,list,full
set wildmenu
set wildignorecase


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
syntax on
colorscheme iceberg
set cursorline

hi CursorLine ctermbg=237
hi Visual ctermbg=239
hi CocErrorHighligh ctermfg=1 ctermbg=203 guifg=#e27878 guibg=#161821

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

function! OpenTypescriptPlayground()
  vs /Users/robin/dev/flexime_github/scripts/ts_playground/index.ts
  nnoremap <buffer> <leader>r :!yarn --cwd /Users/robin/dev/flexime_github/scripts/ts_playground start<cr>
endfunction

command! Config vsp ~/.config/nvim/init.vim

"
" CtrlP config
"
" let g:ctrlp_working_path_mode = 'ra'
" set wildignore+=*/tmp/*,*.so,*.swp,*.zip,node_modules
" let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$|node_modules'
" let g:ctrlp_by_filename = 1
" let g:ctrlp_switch_buffer = 'ET'
" let g:ctrlp_extensions = ['ts']
" command! CtrlPTS call ctrlp#init(ctrlp#ts#id())


"
" NERDTree config
"
let NERDTreeChDirMode=2

if !has('gui_running')
  let g:NERDTreeDirArrowExpandable = "+"
  let g:NERDTreeDirArrowCollapsible = "~"
endif


"
" Airline config
"
" let g:airline_powerline_fonts = 1
let g:airline#parts#ffenc#skip_expected_string='utf-8[unix]'
let g:airline_section_b = ''


"
" ALE config
"
let b:ale_fixers = {'typescript': ['prettier']}
let g:ale_fix_on_save=1

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
nnoremap <Leader>d :CocList diagnostics<CR>


"
" Typescript config
"
let g:deoplete#enable_at_startup = 1

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
" Keybinds
"
let mapleader=" "
nnoremap <Leader>r :!python3 %<CR>
nnoremap <silent> <Leader>c :Files<CR>
nnoremap ¬¥ $
nnoremap - $
vnoremap - $
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
nnoremap <Leader>n :NERDTreeFind<CR>
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
" source ~/.config/nvim/secrets.vim
source ~/.config/nvim/coc.vim
