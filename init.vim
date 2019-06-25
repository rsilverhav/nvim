call plug#begin('~/.local/share/nvim/plugged')

Plug 'HerringtonDarkholme/yats.vim'
Plug 'mxw/vim-jsx'
Plug 'pangloss/vim-javascript'
Plug 'neoclide/coc.nvim', {'tag': '*', 'do': { -> coc#util#install()}}

Plug 'mhartington/oceanic-next'
Plug 'easymotion/vim-easymotion'
Plug 'tpope/vim-fugitive'
Plug 'scrooloose/nerdtree'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'vim-airline/vim-airline'
Plug 'w0rp/ale'
Plug 'AlessandroYorba/Sierra'

call plug#end()

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
"
" Colors
"
syntax on
"color OceanicNext
let g:sierra_Sunset = 1
colorscheme sierra 
set cursorline
highlight SpellBad cterm=None
highlight Label ctermfg=Gray
highlight Statement ctermfg=108
highlight preproc ctermfg=Gray
highlight Search cterm=None ctermbg=146 ctermfg=Black
highlight CocHighlightText ctermbg=240
highlight CocHighlightRead ctermbg=240
highlight CocHighlightWrite ctermbg=240
highlight Comment ctermfg=242


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
    silent execute "grep! -rI --exclude-dir={node_modules,build,static,.git} --exclude=stats.json " . shellescape(query) . " ."
    copen
    redraw!
  endif
endfunction

function! SeachMdn(text)
  let query = a:text
  if query == ""
    let query = input('Search MDN: ')
  endif
  silent execute "!/Applications/Google\\\ Chrome.app/Contents/MacOS/Google\\\ Chrome \"https://developer.mozilla.org/en-US/search?q=" . query . "\""
endfunction

command! Config vsp ~/.config/nvim/init.vim

"
" CtrlP config
"
let g:ctrlp_working_path_mode = 'ra'
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,node_modules
let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$|node_modules'
let g:ctrlp_by_filename = 1
let g:ctrlp_switch_buffer = 'ET'
let g:ctrlp_extensions = ['ts']
command! CtrlPTS call ctrlp#init(ctrlp#ts#id())


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


"
" Typescript config
"
let g:deoplete#enable_at_startup = 1

"
" Keybinds
"
let mapleader=" "
nnoremap <Leader>r :!python3 %<CR>
nnoremap <Leader>c :CtrlP<CR>
nnoremap ¬¥ $
nnoremap - $
vnoremap - $
vnoremap <C-f> :call Ctrlf(GetVisual())<CR>
nnoremap <C-f> :call Ctrlf("")<CR>
nnoremap <Leader>* :call Ctrlf(expand("<cword>"))<CR>
map <Leader> <Plug>(easymotion-prefix)
nnoremap <C-t> :tabnew<CR>
nnoremap <C-j> :tabprevious<CR>
nnoremap <C-k> :tabnext<CR>
nnoremap <C-g> :TSTypeDef<CR>
nnoremap <Leader>t :CtrlPTS<CR>
nnoremap <Leader>s :call OpenCssTsx()<CR>
nnoremap <Leader>v :ALEFix prettier<CR>
nnoremap <Leader>g :Gtabedit :<CR>:set previewwindow<CR>
nnoremap <Leader>C :CtrlPBuffer<CR>
nnoremap <Leader>m :call SeachMdn("")<CR>
vnoremap <Leader>m :call SeachMdn(GetVisual())<CR>
nnoremap n nzz
nnoremap N Nzz
nnoremap Ö :
vnoremap Ö :
map <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
      \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
      \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

imap jk <ESC>

"
" Source
"
source ~/.config/nvim/secrets.vim
source ~/.config/nvim/coc.vim
