function! utils#autocomplete#get_docker_images( arg_lead, cmd_line, cursor_pos ) abort
    return join( systemlist( 'docker images --filter "dangling=false" --format "{{.Repository}}"' ), "\n" )
endfunction

function! utils#autocomplete#get_docker_containers( arg_lead, cmd_line, cursor_pos ) abort
    return join( systemlist( 'docker ps --format "{{.Names}}"' ), "\n" )
endfunction

