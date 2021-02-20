# vim-dockerize
A plugin for running commands in docker containers

## **Usage**

### Requirements

Docker is needed, obviously.

### **Commands**

- **`:DockerizeImages`** list available images
- **`:DockerizeContainers`** list running containers
- **`:DockerizeRun`** runs a docker image
- **`:DockerizeStop`** stops a given docker container ( stops target container if called with no arguments )
- **`:DockerizeExec`** docker exec a command for the target container
- **`:DockerizeChangeTarget`** change target container
- **`:DockerizeShell`** start a shell in target container

### **Variables**

- **`g:dockerize_target_container`** a container against which all commands will be executed, default: `''`
- **`g:dockerize_run_usr_args`** `docker run` user arguments, default: `''`
- **`g:dockerize_exec_usr_args`** `docker exec` user arguments, default: `''`
