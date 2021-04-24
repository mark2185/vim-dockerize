" Prints warning message
function! s:Warning(msg) abort
    echohl WarningMsg |
                \ echomsg a:msg |
                \ echohl None
endfunction

let s:dockerize_buffer = 'Dockerize'
let s:dockerize_job    = {}

function! s:createQuickfix() abort
    let l:bufnr = bufnr(s:dockerize_buffer)
    if l:bufnr == -1
        return
    endif

    execute 'cgetbuffer ' . l:bufnr

    call setqflist( [], 'a', { 'title' : s:dockerize_job[ 'cmd' ] } )
endfunction

function! s:createBuffer() abort
    silent execute 'bo 10split ' . s:dockerize_buffer
    setlocal bufhidden=hide buftype=nofile buflisted nolist
    setlocal noswapfile nowrap nomodifiable

    nnoremap <silent> <buffer> <c-c> :call utils#exec#stopJob()<CR>
    return winbufnr(0)
endfunction

function! s:deleteBuffer() abort
    if bufnr(s:dockerize_buffer) == -1
        return
    endif

    execute 'bwipeout ' . s:dockerize_buffer
endfunction

function! s:jobClosed(channel) abort
    silent call s:createQuickfix()
    silent call s:deleteBuffer()
    copen
    cbottom
    let s:dockerize_job = {}
endfunction

function! utils#exec#stopJob() abort
    if empty(s:dockerize_job)
        return
    endif

    let l:job = s:dockerize_job['job']
    try | call job_stop(l:job) | catch | endtry

    call utils#common#Warning('Job stopped!')

    call s:createQuickfix()
    call s:deleteBuffer()
    let s:dockerize_job = {}
    copen
    cbottom
endfunction

function! s:startJob( cmd ) abort
    let l:bufnr = s:createBuffer()
    let l:job = job_start( a:cmd, 
                \ { 'out_io' : 'buffer', 'out_buf' : l:bufnr, 'out_modifiable' : 0,
                \   'err_io' : 'buffer', 'err_buf' : l:bufnr, 'err_modifiable' : 0,
                \   'close_cb' : function('s:jobClosed') } )
    let s:dockerize_job = { 'job' : l:job, 'cmd' : join( a:cmd ) }
endfunction

function! utils#exec#executeCommand( ... ) abort
    cclose
    let l:openbufnr = bufnr(s:dockerize_buffer)
    if l:openbufnr != -1
        call utils#common#Warning('Async execute is already running')
        return -1
    endif

    silent call s:startJob( split( a:1 ) )
endfunction
