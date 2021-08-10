function! utils#autocomplete#GetImages( arg_lead, cmd_line, cursor_pos ) abort
    return systemlist( 'docker images --filter "dangling=false" --format "{{.Repository}}"' )
                \ ->sort()
                \ ->uniq()
                \ ->join("\n")
endfunction

function! utils#autocomplete#GetContainers( arg_lead, cmd_line, cursor_pos ) abort
    return systemlist( 'docker ps --format "{{.Names}}"' )->join("\n")
endfunction

