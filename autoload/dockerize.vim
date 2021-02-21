
function! dockerize#dockerize_change_target( container_name ) abort
    let g:dockerize_target_container = a:container_name
endfunction

function! dockerize#list_images( ... ) abort
    return 'docker images'
endfunction

function! dockerize#list_containers( ... ) abort
    return 'docker ps -a'
endfunction

function! dockerize#run_docker_image( image, ... ) abort
    let l:command = printf( "docker run %s %s", g:dockerize_run_usr_args, a:image )
    call utils#exec#executeCommand( l:command )
    let g:dockerize_target_container = systemlist( 'docker ps -n1 --format "{{.Names}}"' )[ 0 ]
    echom 'Started container ' . g:dockerize_target_container
endfunction

function! dockerize#run_command_in_docker( ... ) abort
    if ( !a:0 && g:dockerize_target_container ==# '' )
        echom "Missing target container!"
        return
    endif
    return printf( "docker exec %s -i %s %s", g:dockerize_exec_usr_args, g:dockerize_target_container, join( a:000, ' ' ) )
endfunction

function! dockerize#run_docker_shell( ... ) abort
    if ( !a:0 && g:dockerize_target_container ==# '' )
        echom "Missing target container!"
        return
    endif
    execute 'terminal !' . printf( "docker exec %s -i %s", g:dockerize_exec_usr_args, a:0 ? a:1 : g:dockerize_target_container )
endfunction

function! dockerize#stop_docker_container( ... ) abort
    let l:container_name = get( a:, '1', g:dockerize_target_container )
    echom 'Stopping container ' . l:container_name . '...'
    call systemlist( 'docker stop ' . l:container_name )
    " TODO: lambda or :Dispatch
    echom 'Stopped'
endfunction

function! dockerize#inspect_container( ... ) abort
    if ( !a:0 && g:dockerize_target_container ==# '' )
        echom "Missing target container!"
        return
    endif
    return 'docker inspect ' . a:0 ? a:1 : g:dockerize_target_container
endfunction

