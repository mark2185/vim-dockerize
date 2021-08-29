" dockerize.vim - Run commands in docker containers
" Maintainer: Luka Markušić
" Version:    0.0.6

if exists('g:loaded_dockerize_plugin')
    finish
endif
let g:loaded_dockerize_plugin = 1

let g:dockerize_target_container   = get( g:, 'dockerize_target_container'  , ''          )
let g:dockerize_run_usr_args       = get( g:, 'dockerize_run_usr_args'      , ''          )
let g:dockerize_exec_usr_args      = get( g:, 'dockerize_exec_usr_args'     , ''          )
let g:dockerize_shell              = get( g:, 'dockerize_shell'             , '/bin/bash' )
let g:dockerize_enable_mappings    = get( g:, 'dockerize_enable_mappings'   , v:false     )
let g:dockerize_mode               = get( g:, 'dockerize_mode'              , v:false     )
let g:dockerize_term_close_on_exit = get( g:, 'dockerize_term_close_on_exit', v:true     )

" TODO:
" <Dockerize> should behave like :Git
" • space should toggle active container
" • i should toggle images
" • c should toggle containers
" • v verbose ( show stopped containers )
" • X delete a container
" • s start a container
" • S stop a container
" cmake kits for building in docker

" TODO: this file causes performance issues in insert mode
if g:dockerize_enable_mappings
    nnoremap <leader>ds :DockerizeShell<CR>
    nnoremap <leader>dd :DockerizeStop<Space>
    nnoremap <leader>dr :DockerizeRun<Space>
    nnoremap <leader>di :DockerizeImages<CR>
    nnoremap <leader>dc :DockerizeContainers<CR>
    nnoremap <leader>dt :DockerizeChangeTarget<Space>
endif

command! -nargs=0                                                           DockerizeImages       call utils#docker#GetImages()
command! -nargs=0                                                           DockerizeContainers   call dockerize#getContainers()
command! -nargs=? -complete=customlist,utils#autocomplete#CompleteDockerContainers DockerizeInspect      call dockerize#inspectContainer(<f-args>)

command! -nargs=+ -complete=customlist,utils#autocomplete#CompleteDockerImages     DockerizeRun          call dockerize#run_docker_image(<f-args>)
command! -nargs=1 -complete=customlist,utils#autocomplete#CompleteDockerContainers DockerizeRemove       call dockerize#remove_docker_container(<f-args>)
command! -nargs=? -complete=customlist,utils#autocomplete#CompleteDockerContainers DockerizeStop         call dockerize#stop_docker_container(<f-args>)
command! -nargs=+ -complete=customlist,utils#autocomplete#CompleteDockerContainers DockerizeExec         call utils#exec#executeAsyncCommand( dockerize#run_command_in_docker(<f-args>) )
command! -nargs=? -complete=customlist,utils#autocomplete#CompleteDockerContainers DockerizeShell        call dockerize#RunShell(<f-args>)
command! -nargs=? -complete=customlist,utils#autocomplete#CompleteDockerContainers DockerizeChangeTarget call dockerize#DockerizeChangeTarget(<f-args>)
command! DockerizeWorkbench call utils#workbench#WorkbenchToggle()
