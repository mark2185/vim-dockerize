function! utils#exec#executeCommand( ... ) abort
    if ( !a:0 )
        return
    endif
    let l:s_out = system( a:1 )
    cgetexpr l:s_out
    copen
endfunction
