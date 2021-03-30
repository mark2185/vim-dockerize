
function! dockerize#dockerize_change_target( ... ) abort
    if !a:0
        if g:dockerize_target_container !=# ''
            echo 'Current container: ' . g:dockerize_target_container
        else
            echo 'No target container'
        endif
        return
    endif
    let g:dockerize_target_container = a:1
endfunction

function! dockerize#list_images( ... ) abort
    return 'docker images'
endfunction

function! dockerize#list_containers( ... ) abort
    return 'docker ps -a'
endfunction

function! dockerize#run_docker_image_callback( channel, message )
    let g:dockerize_target_container = systemlist( 'docker ps -n1 --format "{{.Names}}"' )[ 0 ]
    echom 'Started ' . g:dockerize_target_container
    let g:docker_mode = v:true
endfunction

function! dockerize#run_docker_image( image, ... ) abort
    let l:command = printf( "docker run %s %s", g:dockerize_run_usr_args, a:image )
    let s:job = job_start( split( l:command ), { "callback" : "dockerize#run_docker_image_callback" } )
endfunction

function! dockerize#stop_docker_container( ... ) abort
    let l:container_name = get( a:, '1', g:dockerize_target_container )
    let s:job = job_start( [ 'docker', 'stop', l:container_name ], { "callback" : { ch, msg -> execute( 'echom Stopped.' ) } } )
endfunction

function! dockerize#run_command_in_docker( ... ) abort
    if ( g:dockerize_target_container ==# '' )
        echom "Missing target container!"
        return
    endif
    return printf( "docker exec %s -i %s %s", g:dockerize_exec_usr_args, g:dockerize_target_container, join( a:000, ' ' ) )
endfunction

function! dockerize#run_docker_shell( ... ) abort
    if ( g:dockerize_target_container ==# '' )
        echom "Missing target container!"
        return
    endif
    execute 'bo terminal ++close ' . printf( "docker exec %s -it %s %s", g:dockerize_exec_usr_args, g:dockerize_target_container, g:dockerize_shell )
endfunction

function! dockerize#remove_docker_container( ... ) abort
    let l:container_name = get( a:, '1', g:dockerize_target_container )
    echom 'Removing container ' . l:container_name . '...'
    call utils#exec#executeCommand( 'docker rm ' . l:container_name )
endfunction

function! dockerize#inspect_container( ... ) abort
    if ( !a:0 && g:dockerize_target_container ==# '' )
        echom "Missing target container!"
        return
    endif
    return 'docker inspect ' . a:0 ? a:1 : g:dockerize_target_container
endfunction

