# vim-dockerize
A plugin for running commands in docker containers

**NOTE:** it is highly experimental and subject to change.

## **Usage**

### Requirements

Docker is needed, obviously.
Tab-completion for image names and container names is available.

### **Commands**

- **`:DockerizeImages`** list available images
- **`:DockerizeContainers`** list all containers
- **`:DockerizeInspect`** inspect a container
- **`:DockerizeRun`** runs a docker image and sets it as currently active container, using `g:cmake_run_usr_args`
- **`:DockerizeStop`** stops a given docker container ( stops target container if called with no arguments ), resets currently active container
- **`:DockerizeExec`** docker exec a command for the target container, using `g:cmake_exec_usr_args`
- **`:DockerizeChangeTarget`** change target container, prints out current target if no args given
- **`:DockerizeShell`** start a given shell in target container. Default is `/bin/bash`

### **Variables**

- **`g:dockerize_target_container`** a container against which all commands will be executed, default: `''`
- **`g:dockerize_run_usr_args`** `docker run` user arguments, default: `''`
- **`g:dockerize_exec_usr_args`** `docker exec` user arguments, default: `''`
- **`g:dockerize_shell`** shell to be launched in `:DockerizeShell`, default: `/bin/bash`
- **`g:dockerize_enable_mappings`** enable default mappings

### **Default mappings**
```
nnoremap <leader>di :DockerizeImages<CR>
nnoremap <leader>dc :DockerizeContainers<CR>
nnoremap <leader>ds :DockerizeShell<CR>
nnoremap <leader>dr :DockerizeRun 
nnoremap <leader>dd :DockerizeStop 
nnoremap <leader>dt :DockerizeChangeTarget 
```

### Examples

If you want to build your code in docker, use this as a template:
```
let g:dockerize_run_usr_args = expand(
            \ join([
            \   '--interactive',
            \   '--detach',
            \   '--rm',
            \   '-v$PWD:$PWD:delegated',
            \   '-v$HOME/.conan:/root/.conan:delegated',
            \   '-v$HOME/.ssh:/root/.ssh:ro,cached',
            \   '-v/etc/passwd:/etc/passwd',
            \   '-w/home/build',
            \   '--privileged'
            \]))

let g:dockerize_exec_usr_args = '-e HOME=/root -w/home/build --privileged'

execute 'nnoremap <leader>, :DockerizeExec cmake -GNinja ' . $PWD .'<CR>'
         nnoremap <leader>. :DockerizeExec ninja<CR>
         nnoremap <leader>c :DockerizeExec ctest -j4 --output-on-failure<CR>
```

With this, the compilation will populate the quickfix list with the correct paths so you can jump straight to the bugs.
