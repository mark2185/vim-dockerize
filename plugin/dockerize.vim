" dockerize.vim - Run commands in docker containers
" Maintainer: Luka Markušić
" Version:    0.0.6

if exists('g:loaded_dockerize_plugin')
    finish
endif
let g:loaded_dockerize_plugin = 1

let g:dockerize_target_container = get( g:, 'dockerize_target_container', '' )
let g:dockerize_run_usr_args     = get( g:, 'dockerize_run_usr_args'    , '' )
let g:dockerize_exec_usr_args    = get( g:, 'dockerize_exec_usr_args'   , '' )
let g:dockerize_shell            = get( g:, 'dockerize_shell'           , '/bin/bash' )
let g:dockerize_enable_mappings  = get( g:, 'dockerize_enable_mappings' , v:false )
let g:dockerize_mode             = get( g:, 'dockerize_mode'            , v:false )

" TODO:
" <Dockerize> should behave like :Git
" • space should toggle active container
" • i should toggle images
" • c should toggle containers
" • v verbose ( show stopped containers )
" • dd stop a container
" • X delete a container
" cmake kits for building in docker

if g:dockerize_enable_mappings
    nnoremap <leader>ds :DockerizeShell<CR>
    nnoremap <leader>dd :DockerizeStop 
    nnoremap <leader>dr :DockerizeRun 
    nnoremap <leader>di :DockerizeImages<CR>
    nnoremap <leader>dc :DockerizeContainers<CR>
    nnoremap <leader>dt :DockerizeChangeTarget 
endif

command! -nargs=0                                                           DockerizeImages       call dockerize#getImages()
command! -nargs=0                                                           DockerizeContainers   call dockerize#getContainers()
command! -nargs=? -complete=custom,utils#autocomplete#get_docker_containers DockerizeInspect      call dockerize#inspectContainer(<f-args>)

command! -nargs=+ -complete=custom,utils#autocomplete#get_docker_images     DockerizeRun          call dockerize#run_docker_image(<f-args>)
command! -nargs=1 -complete=custom,utils#autocomplete#get_docker_containers DockerizeRemove       call dockerize#remove_docker_container(<f-args>)
command! -nargs=? -complete=custom,utils#autocomplete#get_docker_containers DockerizeStop         call dockerize#stop_docker_container(<f-args>)
command! -nargs=+ -complete=custom,utils#autocomplete#get_docker_containers DockerizeExec         call utils#exec#executeCommand( dockerize#run_command_in_docker(<f-args>) )
command!          -complete=custom,utils#autocomplete#get_docker_containers DockerizeShell        call dockerize#run_docker_shell()
command! -nargs=? -complete=custom,utils#autocomplete#get_docker_containers DockerizeChangeTarget call dockerize#dockerize_change_target(<f-args>)
