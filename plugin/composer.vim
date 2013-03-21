" Composer plugin for VIM
" Maintainer: Denis Tukalenko <detook@gmail.com>
" Version:    0.1

" Line-continuation
let s:save_cpo = &cpo
set cpo&vim

" If plugin already loaded finish script execution
if exists("g:loaded_Composer")
    finish
endif
let g:loaded_Composer = 1

" Set PHP binary path
if !exists("g:php_bin")
    let g:php_bin = "php"
endif

let s:composer_phar = 'composer.phar'

" Defaults options for composer
if !exists("g:Composer_defaults")
    " Gvim does not process ansi output
    " not sure about other GUI's
    let g:Composer_defaults = ""
    if has('gui_running')
        let g:Composer_defaults = "--no-ansi"
    endif
endif

function! s:Execute(cmd)
    execute a:cmd
endfunction

function! s:ComposerRun(args)
    let cmd = g:Composer_defaults." ".a:args
    call s:Execute('!'.g:php_bin.' '.s:composer_phar.' '.cmd)
endfunction

function! s:ComposerInstall()
    let cmd = g:Composer_defaults.' install' 
    call s:Execute('!'.g:php_bin.' '.s:composer_phar.' '.cmd)
endfunction

function! s:ComposerUpdate()
    let cmd = g:Composer_defaults.' update' 
    call s:Execute('!'.g:php_bin.' '.s:composer_phar.' '.cmd)
endfunction

" Open output in the buffer
function s:ComposerOpenBuffer(output)
    " is there phpunit_buffer?
    if exists('g:Composer_buffer') && bufexists(g:Composer_buffer)
        let composer_win = bufwinnr(g:Composer_buffer)
        " is buffer visible?
        if composer_win > 0
            " switch to visible composer buffer
            execute composer_win . "wincmd w"
        else
            " split current buffer, with Composer_buffer
            execute "sb ".g:Composer_buffer
        endif
        " Composer_buffer is opened, clear content
        setlocal modifiable
        silent %d
    else
        " there is no composer_buffer create new one
        new
        let g:Composer_buffer = bufnr('%')
    endif

    setlocal buftype=nofile modifiable bufhidden=hide
    silent put=a:output
    setlocal nomodifiable

endfunction

" php composer.phar
if !exists(":Composer")
    command -nargs=? Composer :call s:ComposerRun(<q-args>)
endif

" php composer.phar install
if !exists(":ComposerInstall")
    command -bang -nargs=? ComposerInstall :call s:ComposerInstall()
endif

" php composer.phar update
if !exists(":ComposerUpdate")
    command -bang -nargs=? ComposerUpdate :call s:ComposerUpdate()
endif

" Restore line-continuation
let &cpo = s:save_cpo
unlet s:save_cpo

