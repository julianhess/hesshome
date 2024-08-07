if exists('#redhat')
	au! redhat 
endif

set number
set title
set nohlsearch
set noea

autocmd VimEnter * set autochdir

syntax on
set spell

set colorcolumn=80

set foldcolumn=1
set foldmethod=marker

noremap <Leader>c :set cursorline! cursorcolumn!<CR>
noremap <Leader>h :set hlsearch!<CR>

" colorscheme stuff
" set t_Co=256
colorscheme slatejh
highlight clear SpellCap
highlight SpellCap term=underline ctermbg=Blue ctermfg=Black
highlight clear SpellBad
highlight SpellBad term=standout ctermfg=7 ctermbg=1 cterm=bold 
highlight Search ctermbg=162 ctermfg=Black

set tw=0
set wm=0
set fo-=t
set fo-=c
set fo-=r
set fo-=o
"set fo-=c
"set fo-=r
"set fo-=o

" autocommands
autocmd FileType matlab setl sw=2 sts=2 " match Mike's MATLAB indent style
autocmd FileType c,cpp setl sw=3 sts=3 ts=3 " for C
autocmd FileType perl,python,sh,awk,ruby setl ts=4 sw=4 sts=0 " for Perl/Python/Bash/AWK/Ruby
autocmd FileType python set expandtab
autocmd FileType perl,sh,python,R,java set nospell " syntax file tries to spellcheck everything
autocmd FileType java,javascript setl ts=4 sw=4 sts=4 " for Java/Javascript (to match Mike's style)
autocmd FileType * setl fo-=c fo-=r fo-=o

" to save/load folds on write/read
autocmd BufWrite * mkview
autocmd BufRead * silent loadview

autocmd FileType maf,tsv,csv,txt filetype plugin on " to allow for CSV plugin
let g:csv_delim="	"

"filetype indent off

"tslime config
vmap <C-c><C-c> <Plug>SendSelectionToTmux
"nmap <C-c><C-c> <Plug>NormalModeSendToTmux
nmap <C-c>r <Plug>SetTmuxVars

let g:tslime_always_current_session = 1
let g:tslime_always_current_window = 1

"showmarks config
highlight ShowMarksHLl ctermfg=Yellow ctermbg=Black
highlight ShowMarksHLo ctermfg=Red ctermbg=Black
let g:showmarks_include="abcdefghijklmnopqrstuvwxyz.'`^<>[]"
let g:showmarks_textlower="\t"
let g:showmarks_textother="\t"
