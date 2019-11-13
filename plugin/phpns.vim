" Inserts 'use' statements for the class under the cursor
" Makes use of tag files
"
" Maintainer: Arnaud Le Blanc <arnaud.lb at gmail dot com>
" URL: https://github.com/arnaud-lb/vim-php-namespace
"
" This is an adaptation of a script found at http://vim.wikia.com/wiki/Add_Java_import_statements_automatically

let s:capture = 0

let g:php_namespace_sort = get(g:, 'php_namespace_sort', "'{,'}-1sort i")

let g:php_namespace_sort_after_insert = get(g:, 'php_namespace_sort_after_insert', 0)

function! PhpFindMatchingUse(name)

    " matches use [function] Foo\Bar as <name>
    let pattern = '\%(^\|\r\|\n\)\s*use\%(\_s+function\)\?\_s\+\_[^;]\{-}\_s*\(\_[^;,]*\)\_s\+as\_s\+' . a:name . '\_s*[;,]'
    let fqn = s:searchCapture(pattern, 1)
    if fqn isnot 0
        return fqn
    endif

    " matches use [function] Foo\<name>
    let pattern = '\%(^\|\r\|\n\)\s*use\%(\_s+function\)\?\_s\+\_[^;]\{-}\_s*\(\_[^;,]*\%(\\\|\_s\)' . a:name . '\)\_s*[;,]'
    let fqn = s:searchCapture(pattern, 1)
    if fqn isnot 0
        return fqn
    endif

endfunction

function! PhpFindFqn(name)
    let restorepos = line(".") . "normal!" . virtcol(".") . "|"
    let loadedCount = 0
    let tags = []

    try
        let fqn = PhpFindMatchingUse(a:name)
        if fqn isnot 0
            return ['class', fqn]
        endif

        let tags = taglist("^".a:name."$")

        if len(tags) < 1
            throw "No tag were found for ".a:name."; is your tag file up to date? Tag files in use: ".join(tagfiles(),',')
        endif

        " see if some of the matching files are already loaded
        for tag in tags
            if bufexists(tag['filename'])
                let loadedCount += 1
            endif
        endfor

        exe "ptjump " . a:name
        try
            wincmd P
        catch /.*/
            return
        endtry
        1
        if search('^\s*\%(/\*.*\*/\s*\)\?\%(\%(abstract\|final\)\_s\+\)*\%(class\|interface\|trait\)\_s\+' . a:name . '\>') > 0
            if search('^\%(<?\%(php\s\+\)\?\)\?\s*namespace\s\+', 'be') > 0
                let start = col('.')
                call search('\([[:blank:]]*[[:alnum:]\\_]\)*', 'ce')
                let end = col('.')
                let ns = strpart(getline(line('.')), start, end-start)
                return ['class', ns . "\\" . a:name]
            else
                return ['class', a:name]
            endif
        elseif search('^\s*function\_s\+' . a:name . '\>') > 0
            if search('^\%(<?\%(php\s\+\)\?\)\?\s*namespace\s\+', 'be') > 0
                let start = col('.')
                call search('\([[:blank:]]*[[:alnum:]\\_]\)*', 'ce')
                let end = col('.')
                let ns = strpart(getline(line('.')), start, end-start)
                return ['function', ns . "\\" . a:name]
            else
                return a:name
            endif

        else
            throw a:name . ": not found!"
        endif
    finally
        let loadedCountNew = 0
        for tag in tags
            if bufexists(tag['filename'])
                let loadedCountNew += 1
            endif
        endfor

        if loadedCountNew > loadedCount
            " wipe preview window (from buffer list)
            silent! wincmd P
            if &previewwindow
                bwipeout
            endif
        else
            wincmd z
        endif
        exe restorepos
    endtry
endfunction

function! PhpInsertUse()
    exe "normal mz"
    " move to the first component
    " Foo\Bar => move to the F
    call search('[[:alnum:]\\:_]\+', 'bcW')
    let cur_name = expand("<cword>")
    try
        let search_phrase = substitute(cur_name, "::class", "", "")
        let fqn = PhpFindMatchingUse(search_phrase)
        if fqn isnot 0
            exe "normal! `z"
            echo "import for " . search_phrase . " already exists"
            return
        endif
        let tfqn = PhpFindFqn(search_phrase)
        if tfqn is 0
            echo "fully qualified class name was not found"
            return
        endif
        if tfqn[0] == 'function'
            let use = "use function ".tfqn[1].";"
        else
            let use = "use ".tfqn[1].";"
        endif
        " insert after last use or namespace or <?php
        if search('^use\_s\%(function\_s\+\)\?\_[[:alnum:][:blank:]\\_]*;', 'be') > 0
            call append(line('.'), use)
        elseif search('^\s*namespace\_s\_[[:alnum:][:blank:]\\_]*[;{]', 'be') > 0
            call append(line('.'), "")
            call append(line('.')+1, use)
        elseif search('<?\%(php\)\?', 'be') > 0
            call append(line('.'), "")
            call append(line('.')+1, use)
        else
            call append(1, use)
        endif
        if g:php_namespace_sort_after_insert
            call PhpSortUse()
        endif
    catch /.*/
        echoerr v:exception
    finally
        exe "normal! `z"
    endtry
endfunction

function! PhpExpandClass()
    let restorepos = line(".") . "normal!" . virtcol(".") . "|"
    " move to last element
    call search('\%#[[:alnum:]\\_]\+', 'cW')
    " move to first char of last element
    call search('[[:alnum:]_]\+', 'bcW')
    let cur_class = expand("<cword>")
    let fqn = PhpFindFqn(cur_class)
    if fqn is 0
        return
    endif
    substitute /\%#[[:alnum:]\\_]\+/\=fqn[1]/
    exe restorepos
    " move cursor after fqn
    call search('\([[:blank:]]*[[:alnum:]\\_]\)*', 'ceW')
endfunction

function! s:searchCapture(pattern, nr)
    let s:capture = 0
    let str = join(getline(0, line('$')),"\n")
    call substitute(str, a:pattern, '\=[submatch(0), s:saveCapture(submatch('.a:nr.'))][0]', 'e')
    return s:capture
endfunction

function! s:saveCapture(capture)
    let s:capture = a:capture
endfunction

function! PhpSortUse()
    let restorepos = line(".") . "normal!" . virtcol(".") . "|"
     " insert after last use or namespace or <?php
    if search('^use\_s\_[[:alnum:][:blank:]\\_]*;', 'be') > 0
        execute g:php_namespace_sort
    endif
    exe restorepos
endfunction
