function! Asdfff( ch, msg )
    caddexpr a:msg
endfunction

function! utils#exec#executeCommand( ... ) abort
    if ( !a:0 )
        return
    endif
    cgetexpr []
    call setqflist( [], 'r', { 'title' : a:1 } )
    let s:job = job_start( split(a:1), { "callback" : "Asdfff", 'pty': 1 } )

    bo copen 20
endfunction
