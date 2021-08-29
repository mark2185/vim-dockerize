function! utils#docker#GetImages() abort
    return systemlist( 'docker images' )
endfunction

function! utils#docker#GetContainers() abort
   return systemlist( 'docker ps -a' )
endfunction
