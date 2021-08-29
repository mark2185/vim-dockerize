let s:workbench_winid = -1

let s:help =
            \[
            \ 'Mappings:',
            \ " r - run image",
            \ " s - spawn shell in container",
            \ " X - stop container",
            \ " t - set container as active"
            \]

function s:AppendLineToWorkbench( line, ... ) abort
    let l:position = get( a:, 1, '$' )
    call appendbufline( 'DockerizeWorkbench', l:position, a:line )
endfunction

" TODO: update this only when the workbench is visible,
" i.e. when the tabpage is active
" nomodifiable leaks through
function s:ReloadUI( ... ) abort
    if win_getid() != s:workbench_winid
        return
    end

    let l:cursor_position = getcurpos( s:workbench_winid )
    set modifiable
    %delete _

    call s:AppendLineToWorkbench( '# Press g? to toggle help', 0 )
    $delete _
    if b:show_help
        for msg in s:help
            call s:AppendLineToWorkbench( '# ' . msg )
        endfor
    endif

    call s:AppendLineToWorkbench( '' )

    call s:AppendLineToWorkbench( 'Active container: ' . g:dockerize_target_container )

    call s:AppendLineToWorkbench( '' )

    let b:mapped_rows = #{ images: [], containers: [] }
    for line in utils#docker#GetImages()
        call s:AppendLineToWorkbench( line )
        if line !~# "REPOSITORY"
            call add( b:mapped_rows.images, line("$") )
        endif
    endfor
    call s:AppendLineToWorkbench( '' )
    call s:AppendLineToWorkbench( '================================================================================' )
    call s:AppendLineToWorkbench( '' )
    for line in utils#docker#GetContainers()
        call s:AppendLineToWorkbench( line )
        if line !~# "CONTAINER ID"
            call add( b:mapped_rows.containers, line("$") )
        endif
    endfor

    set nomodifiable
    call setpos('.', l:cursor_position )
endfunction

let s:mappings = {
            \ 'start': { 'key': 'r' },
            \ 'stop' : { 'key': 'X' },
            \ 'shell': { 'key': 's' },
            \ 'activate': { 'key': 't' } }

function! s:MappingsResolver( key ) abort
    function! CursorOnImage() closure
        return index( b:mapped_rows.images, l:line ) != -1
    endfunction

    function! CursorOnContainer() closure
        return index( b:mapped_rows.containers, l:line ) != -1
    endfunction

    "echom string(b:mapped_rows)
    let l:line = line('.')
    " echom "Key pressed: " . a:key
    " s - shell
    if a:key ==# 's'
        if CursorOnContainer()
            let l:container = getline( '.' )->split()[-1]
            execute 'DockerizeShell ' . l:container
        endif
    " t - change target
    elseif a:key ==# 't'
        if CursorOnContainer()
            let l:container = getline( '.' )->split()[-1]
            execute 'DockerizeChangeTarget ' . l:container
        endif
    " r - docker run
    elseif a:key ==# 'r'
        if CursorOnImage()
            let l:image = getline( '.' )->split()[2]
            execute 'DockerizeRun ' . l:image
        endif
    elseif a:key ==# 'c'
        if CursorOnImage()
            " TODO: run but first change parameters
        endif
    elseif a:key ==# 'X' " container stop
        if CursorOnContainer()
            let l:container = getline( '.' )->split()[-1]
            execute 'DockerizeStop ' . l:container
        endif
    endif
endfunction

" TODO: this way the docker workbench has to be closed with `q`
function! utils#workbench#WorkbenchToggle() abort
    if s:workbench_winid == -1
        silent tabe DockerizeWorkbench
        let s:workbench_winid = win_getid()
        setlocal filetype=DockerizeWorkbench buftype=nofile cursorline winfixheight bufhidden=delete nomodifiable nobuflisted noswapfile
        nnoremap <buffer> g? :call utils#workbench#HelpToggle()<CR>
        for [ cmd, d ] in s:mappings->items()
            execute printf( "nnoremap <silent> <buffer> %s :<c-u>call <SID>MappingsResolver('%s')\<CR>", d.key, d.key )
        endfor
        let b:show_help = 0
        call s:ReloadUI()
        let s:workbench_ui_thread = timer_start( 2000, function('s:ReloadUI'), { 'repeat': -1 } )
    elseif win_getid() != s:workbench_winid
        call win_gotoid( s:workbench_winid )
    else
        call timer_stop( s:workbench_ui_thread )
        let s:workbench_winid = -1
        tabclose
    endif
endfunction

function! utils#workbench#HelpToggle() abort
    let b:show_help = !b:show_help
    call s:ReloadUI()
endfunction

augroup Dockerize
    autocmd!
augroup END
