" dockerize.vim - Run commands in docker containers
" Maintainer: Luka Markušić
" Version:    0.0.5

if exists('g:loaded_dockerize_plugin')
    finish
endif
let g:loaded_dockerize_plugin = 1

let g:dockerize_target_container = get( g:, 'dockerize_target_container', '' )
let g:dockerize_run_usr_args     = get( g:, 'dockerize_run_usr_args'    , '' )
let g:dockerize_exec_usr_args    = get( g:, 'dockerize_exec_usr_args'   , '' )

" <Dockerize> should behave like :Git
" space should toggle active container
" i should toggle images
" c should toggle containers
" v verbose ( show stopped containers )
" dd stop a container
" X delete a container

" TODO: cannot use flag --tty
" let g:dockerize_run_usr_args = '--interactive --detach --rm -u$(id -u):$(id -g) -v$HOME/.bashrc:$HOME/.bashrc -v$(pwd):/home/source:ro -v$HOME/.conan:$HOME/.conan -v$HOME/.ssh:$HOME/.ssh -v/etc/passwd:/etc/passwd'
" let g:dockerize_exec_usr_args = '-w/home/build'

command! -nargs=0 DockerizeImages     call utils#exec#executeCommand( dockerize#list_images() )
command! -nargs=0 DockerizeContainers call utils#exec#executeCommand( dockerize#list_containers() )
command! -nargs=? -complete=custom,utils#autocomplete#get_docker_containers DockerizeInspect    call utils#exec#executeCommand( dockerize#inspect_container(<f-args>) )

command! -nargs=+ -complete=custom,utils#autocomplete#get_docker_images     DockerizeRun          call dockerize#run_docker_image(<f-args>)
command! -nargs=? -complete=custom,utils#autocomplete#get_docker_containers DockerizeStop         call dockerize#stop_docker_container(<f-args>)
command! -nargs=+ -complete=custom,utils#autocomplete#get_docker_containers DockerizeExec         call utils#exec#executeCommand( dockerize#run_command_in_docker(<f-args>) )
command! -nargs=? -complete=custom,utils#autocomplete#get_docker_containers DockerizeShell        call dockerize#run_docker_shell(<f-args>)
command! -nargs=1 -complete=custom,utils#autocomplete#get_docker_containers DockerizeChangeTarget call dockerize#dockerize_change_target(<f-args>)
