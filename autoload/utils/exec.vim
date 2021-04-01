function! utils#exec#executeCommand( ... ) abort
    if ( !a:0 )
        echom "Nothing to execute!"
        return
    endif

    cgetexpr []
    call setqflist( [], 'r', { 'title' : a:1 } )
    let s:job = job_start( split(a:1), { 'callback' : { ch, msg -> execute( 'caddexpr msg' ) } } )

    bo copen 20
endfunction
