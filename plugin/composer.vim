" Composer plugin for VIM
" Maintainer: Denis Tukalenko <detook@gmail.com>
" Version:    0.2

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

" is composer.phar installed or not
let s:composer_installed = 0
let b:composer_dir = ""

augroup composer
    autocmd!
    autocmd BufNewFile,BufReadPost * call s:Detect(expand('<amatch>:p'))
augroup END

" all composer.vim commands
let s:commands = []
function! s:command(definition)
    let s:commands += [a:definition]
endfunction

function! s:define_commands()
    for command in s:commands
        exe 'command! -buffer '.command
    endfor
endfunction

" Defaults options for composer
if !exists("g:Composer_defaults")
    " Gvim does not process ansi output
    " not sure about other GUI's
    let g:Composer_defaults = ""
    if has('gui_running')
        let g:Composer_defaults = "--no-ansi"
    endif
endif

function! s:Detect(path)
    let fn = fnamemodify(a:path,':s?[\/]$??')
    let ofn = ""
    let nfn = fn
    while fn != ofn
        if filereadable(fn . '/'.s:composer_phar)
            let s:composer_installed = 1
            let b:composer_dir = fn . '/'

            call s:define_commands()
            return ""
        endif
        let ofn = fn
        let fn = fnamemodify(ofn,':h')
    endwhile
    
    let s:composer_installed = 0
endfunction

function! s:Execute(cmd)
    execute a:cmd
endfunction

" open path in a new buffer
function! s:openFile(path)
    if filereadable(a:path)        
        execute "e ".fnameescape(a:path)
    else
        echo a:path. " is not readable."
    endif
endfunction

function! s:ComposerRun(args)
    if (s:composer_installed == 1)
        let cmd = g:Composer_defaults." --working-dir=\"".b:composer_dir."\" ".a:args
    else
        let cmd = g:Composer_defaults." ".a:args
    endif    
    call s:Execute('!'.g:php_bin.' '.s:composer_phar.' '.cmd)
endfunction

function! s:ComposerInstall()
    call s:ComposerRun('install')
endfunction

function! s:ComposerUpdate()
    call s:ComposerRun('update')
endfunction

function! s:ComposerOpenJson()
    let composer_json_path = b:composer_dir."composer.json"
    call s:openFile(composer_json_path)
endfunction

function! s:ComposerOpenLock()
    let composer_lock_path = b:composer_dir."composer.lock"
    call s:openFile(composer_lock_path)
endfunction

" php composer.phar
if !exists(":Composer")
    call s:command("-nargs=? Composer :call s:ComposerRun(<q-args>)")
endif

" php composer.phar install
if !exists(":ComposerInstall")
    call s:command("-bang -nargs=? ComposerInstall :call s:ComposerInstall()")
endif

" php composer.phar update
if !exists(":ComposerUpdate")
    call s:command("-bang -nargs=? ComposerUpdate :call s:ComposerUpdate()")
endif

" open composer.json in new buffer
if !exists(":ComposerOpenJson")
    call s:command("-bang -nargs=? ComposerOpenJson :call s:ComposerOpenJson()")
endif

" open composer.lock in new buffer
if !exists(":ComposerOpenLock")
    call s:command("-bang -nargs=? ComposerOpenLock :call s:ComposerOpenLock()")
endif

" Restore line-continuation
let &cpo = s:save_cpo
unlet s:save_cpo

