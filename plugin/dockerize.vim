" dockerize.vim - Run commands in docker containers
" Maintainer: Luka Markušić
" Version:    0.0.2

if exists('g:loaded_dockerize_plugin')
    finish
endif
let g:loaded_dockerize_plugin = 1

let g:dockerize_target_container = get( g:, 'dockerize_target_container', '' )
let g:dockerize_run_usr_args     = get( g:, 'dockerize_run_usr_args'    , '' )
let g:dockerize_exec_usr_args    = get( g:, '-w/home/build'             , '' )

" TODO: cannot use flag --tty
let g:dockerize_run_usr_args = '--interactive --detach --rm -u$(id -u):$(id -g) -v$HOME/.bashrc:$HOME/.bashrc -v$(pwd):/home/source:ro -v$HOME/.conan:$HOME/.conan -v$HOME/.ssh:$HOME/.ssh -v/etc/passwd:/etc/passwd'
let g:dockerize_exec_usr_args = '-w/home/build'

function! s:get_docker_images( arg_lead, cmd_line, cursor_pos ) abort
    let l:output_list = []
    for entry in systemlist( 'docker images' )[ 1: ]
        call add( l:output_list, split( entry )[ 0 ] )
    endfor
    return join( l:output_list, "\n" )
endfunction

function! s:get_docker_containers( arg_lead, cmd_line, cursor_pos ) abort
    let l:output_list = []
    for entry in systemlist( 'docker ps -a' )[ 1: ]
        call add( l:output_list, split( entry )[ -1 ] )
    endfor
    return join( l:output_list, "\n" )
endfunction

function! s:dockerize_change_target( container_name ) abort
    let g:dockerize_target_container = a:container_name
endfunction

function! s:run_docker_image( image, ... ) abort
    let l:command = printf( "docker run %s %s", g:dockerize_run_usr_args, a:image )

    let g:dockerize_target_container = systemlist( l:command )[ 0 ]
    echom 'Started container ' . g:dockerize_target_container
endfunction

function! s:run_command_in_docker( ... ) abort
    if ( g:dockerize_target_container ==# '' )
        echom "Missing target container!"
        return
    endif
    let l:cmd = printf( "docker exec %s -i %s %s", g:dockerize_exec_usr_args, g:dockerize_target_container, join( a:000, ' ' ) )
    echom l:cmd
    let l:s_out = system( l:cmd )
    cgetexpr l:s_out
    copen
endfunction

function! s:run_docker_shell( ... ) abort
    if ( g:dockerize_target_container ==# '' )
        echom "Missing target container!"
        return
    endif
    let l:cmd = 'docker exec -w/home/build -i ' . g:dockerize_target_container . ' /bin/bash'
    echom 'Running: ' . l:cmd
endfunction

command! -nargs=+ -complete=custom,s:get_docker_images     DockerizeRun          call s:run_docker_image(<f-args>)
command! -nargs=+ -complete=custom,s:get_docker_containers DockerizeExec         call s:run_command_in_docker(<f-args>)
command! -nargs=? -complete=custom,s:get_docker_containers DockerizeShell        call s:run_docker_shell(<f-args>)
command! -nargs=1 -complete=custom,s:get_docker_containers DockerizeChangeTarget call s:dockerize_change_target(<f-args>)

nnoremap <leader>dr :DockerizeRun 
nnoremap <leader>de :DockerizeExec 
nnoremap <leader>ds :DockerizeShell 
