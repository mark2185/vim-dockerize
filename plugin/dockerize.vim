" dockerize.vim - Run commands in docker containers
" Maintainer: Luka Markušić
" Version:    0.0.1

if exists('g:loaded_dockerize_plugin')
    finish
endif
let g:loaded_dockerize_plugin = 1

let g:dockerize_last_used_container = get( g:, 'dockerize_last_used_container', '' )
let g:dockerize_run_usr_args        = get( g:, 'dockerize_run_usr_args'       , '' )

let g:dockerize_run_usr_args = '--interactive --detach --rm -u$(id -u):$(id -g) -v$HOME/.bashrc:$HOME/.bashrc -v$(pwd):/home/source:ro -v$HOME/.conan:$HOME/.conan -v$HOME/.ssh:$HOME/.ssh -v/etc/passwd:/etc/passwd'

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

function! s:DockerizeRun( image, ... ) abort
    let l:command = 'docker run ' . g:dockerize_run_usr_args
    if ( a:0 == 1 )
        let l:command = join( [ l:command, '--name', a:1 ] )
        let l:dockerize_last_used_container = a:1
    endif

    let l:command = join( [ l:command, a:image ], ' ' )
    let l:s_out = system( l:command )
    cgetexpr l:s_out
    copen

endfunction

function! s:run_command_in_docker( name, ... ) abort
    let l:cmd = 'docker exec -w/home/build -i ' . a:name . ' ' . join( a:000, ' ' )
    echom l:cmd
    let l:s_out = system( l:cmd )
    cgetexpr l:s_out
    copen
endfunction

command! -nargs=+ -complete=custom,s:get_docker_images     DockerizeRun  call s:DockerizeRun(<f-args>)
command! -nargs=+ -complete=custom,s:get_docker_containers DockerizeExec call s:run_command_in_docker(<f-args>)
