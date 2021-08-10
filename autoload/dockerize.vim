" TODO: this should only change it, not print if it's missing
function! dockerize#ChangeTarget( ... ) abort
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

function! dockerize#getImages( ... ) abort
    call utils#exec#executeCommand( 'docker images' )
endfunction

function! dockerize#getContainers( ... ) abort
    call utils#exec#executeCommand( 'docker ps -a' )
endfunction

function! s:LoadTools() abort
    setlocal modifiable
    silent %d _
    let l:cursor_pos = getcurpos()
    if b:show_help
        let l:help = "I am offering you help!"
    else
        let l:help = "# Press ? for help"
    endif
    0put =help

    execute printf("read !docker images")
    $put ="\n"
    execute printf("read !docker ps -a")

    setlocal nomodifiable
    call setpos('.', l:cursor_pos)
endfunction

function! dockerize#ChangeActiveTarget() abort
    let l:current_line = getline('.')
    let l:docker_target = split( l:current_line)[-1]
    call dockerize#ChangeTarget(l:docker_target)
endfunction

function! dockerize#OpenTools() abort
    silent tabedit DockerTools
    let b:show_help = v:false
    setlocal buftype=nofile cursorline bufhidden=delete nobuflisted noswapfile
    setlocal filetype=DockerTools
    call s:LoadTools()

    nnoremap <buffer> <silent> i :call dockerize#ToggleImages()<CR>
    nnoremap <buffer> <silent> c :call dockerize#ToggleContainers()<CR>
    nnoremap <buffer> <silent> <Space> :call dockerize#ChangeActiveTarget()<CR>
    " setlocal nnoremap [ toggle images
    " setlocal nnoremap ] toggle containers
    " autocmd CursorHold <buffer> call s:RefreshUI()
endfunction

function! dockerize#RunImage_callback( channel, message )
    let g:dockerize_target_container = systemlist( 'docker ps -n1 --format "{{.Names}}"' )[ 0 ]
    echom 'Started ' . g:dockerize_target_container
    " let g:dockerize_mode = v:true
endfunction

function! dockerize#error_handling( channel, message )
    echom a:message
endfunction

" TODO: make this write to buffer and `<c-c>` should kill the job
function! dockerize#RunImage( image ) abort
    call utils#exec#executeCommand( printf( "docker run %s %s", g:dockerize_run_usr_args, a:image ) )
    return
    let l:command = printf( "docker run %s %s", g:dockerize_run_usr_args, a:image )
    let s:job = job_start( split( l:command ),
                \{
                    \ "out_cb" : function("dockerize#RunImage_callback"),
                    \ "err_cb" : function("dockerize#error_handling") } )
endfunction

function! dockerize#stop_docker_image_callback( channel, message )
    echom 'Stopped.'
endfunction

function! dockerize#stop_docker_container( ... ) abort
    let l:container_name = get( a:, '1', g:dockerize_target_container )
    echom printf("Stopping '%s'...", l:container_name)
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

function! dockerize#run_docker_shell() abort
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

function! dockerize#inspectContainer( ... ) abort
    let l:container = a:0 ? a:1 : g:dockerize_target_container
    if ( l:container ==# '' )
        echom "Missing target container!"
        return
    endif
    call utils#exec#executeCommand( 'docker inspect ' . l:container  )
endfunction
