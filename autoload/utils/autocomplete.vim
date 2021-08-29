function! utils#autocomplete#CompleteDockerImages( arg_lead, cmd_line, cursor_pos ) abort
    return systemlist( 'docker images --filter "dangling=false" --format "{{.Repository}}"' )
endfunction

function! utils#autocomplete#CompleteDockerContainers( arg_lead, cmd_line, cursor_pos ) abort
    return systemlist( 'docker ps --format "{{.Names}}"' )
endfunction

