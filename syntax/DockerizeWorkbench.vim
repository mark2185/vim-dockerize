if exists('b:current_syntax')
    finish
endif

syn match DockerizeContainerKeyword /\v(CONTAINER ID|IMAGE|COMMAND|CREATED|STATUS|PORTS|NAMES)/
syn match DockerizeImageKeyword /\v(REPOSITORY|TAG|IMAGE ID|CREATED|SIZE)/
syn match DockerizeQuickHelp /\v#.*$/
"syn match VDFilter /\vFilter\(s\): .*$/
"
syn match DockerizeContainerID /\v[a-f0-9]{12}/ containedin=DockerizeContainer
syn region DockerizeContainerCommand start=/\v"/ skip=/\v\\./ end=/\v"/ containedin=DockerizeContainer
syn match DockerizeContainerName /\s\S*$/ containedin=DockerizeContainer contained

syn match DockerizeContainer /\v[a-f0-9]{12}.*$/ contains=DockerizeContainerID,DockerizeContainerCommand,DockerizeContainerName
"syn match VDExitedContainer /\v[a-f0-9]{12}.*Exited.*$/
"syn match VDPausedContainer /\v[a-f0-9]{12}.*(Paused).*$/
"
hi def link DockerizeContainerKeyword Keyword
hi def link DockerizeImageKeyword Keyword
hi def link DockerizeQuickHelp Constant
"hi def link VDFilter Tag
"
"hi def link VDContainerID Identifier
"hi def link VDContainerCommand Function
"hi def link VDContainerName Identifier
hi def link DockerizeContainer String
"hi def link VDExitedContainer Comment
"hi def link VDPausedContainer Constant

let b:current_syntax = 'dockerize-syntax'
