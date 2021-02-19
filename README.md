# vim-dockerize
A plugin for running commands in docker containers

## ** Usage **

### Requirements

Docker is needed, obviously.

### **Commands**

- **`:DockerizeRun`** runs a docker image with a second (optional) argument, the container name (TODO: store the return hash if no name is given)
- **`:DockerizeExec`** docker exec a command for a given container name (first argument)
