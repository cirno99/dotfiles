" .obsidian.vimrc
"
" A small .vimrc for Obsidian vim bindings
"
" To enable this file, you must install the Vimrc Support plugin for Obsidian:
" https://github.com/esm7/obsidian-vimrc-support
"_________________________________________________________________________

" ; (semicolon) - same as : (colon)
nnoremap d x
vnoremap d x
nnoremap x 0v$
vnoremap x j
nnoremap w vw
vnoremap w w<Esc>

nnoremap gh 0
nnoremap gs ^
nnoremap gl $
nnoremap ge G

vnoremap gh 0
vnoremap gs ^
vnoremap gl $
vnoremap ge G



