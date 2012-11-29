" Inserts 'use' statements for the class under the cursor
" Makes use of tag files
"
" Maintainer: Arnaud Le Blanc <arnaud.lb at gmail dot com>
" URL: https://github.com/arnaud-lb/vim-php-namespace
"
" This is an adaptation of a script found at http://vim.wikia.com/wiki/Add_Java_import_statements_automatically

function! PhpFindFqcn(clazz)
    let restorepos = line(".") . "normal!" . virtcol(".") . "|"
    try
        " search matching tags and see if some of the matching files
        " are already loaded
        let tags = taglist("^".a:clazz."$")
        let loadedCount = 0
        for tag in tags
            if bufexists(tag['filename'])
                let loadedCount += 1
            endif
        endfor

        exe "ptjump " . a:clazz
        try
            wincmd P
        catch /.*/
            return
        endtry
        1
        if search('^\s*\%(\%(abstract\|final\)\_s\+\)*\%(class\|interface\|trait\)\_s\+' . a:clazz . '\>') > 0
            if search('^\s*namespace\s\+', 'be') > 0
                let start = col('.')
                call search('\([[:blank:]]*[[:alnum:]\\]\)*', 'ce')
                let end = col('.')
                let ns = strpart(getline(line('.')), start, end-start)
                return ns . "\\" . a:clazz
            else
                throw "Namespace definition for " . a:clazz . " not found!"
            endif
        else
            throw a:clazz . ": class not found!"
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
    call search('[[:alnum:]\\]\+', 'bcW')
    let cur_class = expand("<cword>")
    try
        " this matches
        "  - use Foo\<cur_class>
        "  - use Foo\Bar as <cur_class>
        if search('^\s*use\_s\+\_[^;]*\%(\\\|\_s\)' . cur_class . '\_s*[;,]') > 0
            echo "import for " . cur_class . " already exist"
            exe "normal! `z"
            return
        endif
        let fqcn = PhpFindFqcn(cur_class)
        if fqcn == "0"
            return
        endif
        let use = "use ".fqcn.";"
        " insert after last use or namespace or <?php
        if search('^use\_s\_[[:alnum:][:blank:]\\]*;', 'be') > 0
            call append(line('.'), use)
        elseif search('^\s*namespace\_s\_[[:alnum:][:blank:]\\]*[;{]', 'be') > 0
            call append(line('.'), "")
            call append(line('.')+1, use)
        elseif search('<?\%(php\)\?', 'be') > 0
            call append(line('.'), "")
            call append(line('.')+1, use)
        else
            call append(1, use)
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
    call search('\%#[[:alnum:]\\]\+', 'cW')
    " move to first char of last element
    call search('[[:alnum:]]\+', 'bcW')
    let cur_class = expand("<cword>")
    let fqcn = PhpFindFqcn(cur_class)
    if fqcn == "0"
        return
    endif
    substitute /\%#[[:alnum:]\\]\+/\=fqcn/
    exe restorepos
    " move cursor after fqcn
    call search('\([[:blank:]]*[[:alnum:]\\]\)*', 'ceW')
endfunction

