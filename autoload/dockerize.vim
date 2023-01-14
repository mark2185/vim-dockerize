function! dockerize#DockerizeChangeTarget( ... ) abort
    if !a:0
        if g:dockerize_target_container !=# ''
            echo 'Current container: ' . g:dockerize_target_container
        else
            echo 'No target container'
        endif
        return
    endif
    let g:dockerize_target_container = a:1
    " let g:dockerize_mode = v:true
endfunction

function! dockerize#run_docker_image_callback( channel, message )
    let g:dockerize_target_container = systemlist( 'docker ps -n1 --format "{{.Names}}"' )[ 0 ]
    echom 'Started ' . g:dockerize_target_container
    " let g:dockerize_mode = v:true
endfunction

function! dockerize#error_handling( channel, message )
    echom a:message
endfunction

" TODO: make this write to buffer and `<c-c>` should kill the job
function! dockerize#run_docker_image( image, ... ) abort
    let l:command = printf( "docker run %s %s", g:dockerize_run_usr_args, a:image )
    let s:job = job_start( split( l:command ),
                \{
                    \ "out_cb" : function("dockerize#run_docker_image_callback"),
                    \ "err_cb" : function("dockerize#error_handling") } )
endfunction

function! dockerize#stop_docker_image_callback( channel, message )
    echom 'Stopped.'
endfunction

function! dockerize#stop_docker_container( ... ) abort
    let l:container_name = get( a:, '1', g:dockerize_target_container )
    echom 'Stopping...'
    if !a:0
        let g:dockerize_target_container = ''
        " let g:dockerize_mode = v:false
    endif
    let s:job = job_start(['docker', 'stop', l:container_name], {'callback' : "dockerize#stop_docker_image_callback" })
endfunction

function! dockerize#run_command_in_docker( ... ) abort
    if ( g:dockerize_target_container ==# '' )
        echom "Missing target container!"
        return
    endif
    return printf( "docker exec %s -i %s %s", g:dockerize_exec_usr_args, g:dockerize_target_container, join( a:000, ' ' ) )
endfunction

function! dockerize#RunShell( ... ) abort
    let l:container_name = get( a:, '1', g:dockerize_target_container )
    if ( empty( l:container_name ) )
        echom "Missing target container!"
        return
    endif
    let l:cmd = 'bo terminal ' . g:dockerize_term_close_on_exit ? '++close' : ''
    execute 'bo terminal ++close ' . printf( "docker exec %s -it %s %s", g:dockerize_exec_usr_args, l:container_name, g:dockerize_shell )
endfunction

" TODO:
function! dockerize#remove_image( ... ) abort
    "let l:container_name = get( a:, '1', g:dockerize_target_container )
    "call utils#exec#executeAsyncCommand( 'docker rm ' . l:container_name )
    let l:container_name = get( a:, '1', g:dockerize_target_container )
    echom 'Removing container ' . l:container_name . '...'
    let s:job = job_start(['docker', 'rm', l:container_name], {'callback' : "dockerize#stop_docker_image_callback" })
endfunction

function! dockerize#remove_docker_container( ... ) abort
    "let l:container_name = get( a:, '1', g:dockerize_target_container )
    "call utils#exec#executeAsyncCommand( 'docker rm ' . l:container_name )
    let l:container_name = get( a:, '1', g:dockerize_target_container )
    echom 'Removing container ' . l:container_name . '...'
    let s:job = job_start(['docker', 'rm', l:container_name], {'callback' : "dockerize#stop_docker_image_callback" })
endfunction

function! dockerize#inspectContainer( ... ) abort
    let l:container = a:0 ? a:1 : g:dockerize_target_container
    if ( l:container ==# '' )
        echom "Missing target container!"
        return
    endif
    call utils#exec#executeSyncCommand( 'docker inspect ' . l:container  )
endfunction
