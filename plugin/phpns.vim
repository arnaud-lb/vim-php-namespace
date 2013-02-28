" Inserts 'use' statements for the class under the cursor
" Makes use of tag files
"
" Maintainer: Arnaud Le Blanc <arnaud.lb at gmail dot com>
" URL: https://github.com/arnaud-lb/vim-php-namespace
"
" This is an adaptation of a script found at http://vim.wikia.com/wiki/Add_Java_import_statements_automatically

let s:capture = 0

function! PhpFindMatchingUse(clazz)

    " matches use Foo\Bar as <class>
    let pattern = '\%(^\|\r\|\n\)\s*use\_s\+\_[^;]\{-}\_s*\(\_[^;,]*\)\_s\+as\_s\+' . a:clazz . '\_s*[;,]'
    let fqcn = s:searchCapture(pattern, 1)
    if fqcn isnot 0
        return fqcn
    endif

    " matches use Foo\<class>
    let pattern = '\%(^\|\r\|\n\)\s*use\_s\+\_[^;]\{-}\_s*\(\_[^;,]*\%(\\\|\_s\)' . a:clazz . '\)\_s*[;,]'
    let fqcn = s:searchCapture(pattern, 1)
    if fqcn isnot 0
        return fqcn
    endif

endfunction

function! PhpFindFqcn(clazz)
    let restorepos = line(".") . "normal!" . virtcol(".") . "|"
    let loadedCount = 0
    let tags = []
    try
        let fqcn = PhpFindMatchingUse(a:clazz)
        if fqcn isnot 0
            return fqcn
        endif

        let tags = taglist("^".a:clazz."$")

        if len(tags) < 1
            throw "No tag were found for class ".a:clazz."; is your tag file up to date? Tag files in use: ".join(tagfiles(),',')
        endif

        " see if some of the matching files are already loaded
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
        let fqcn = PhpFindMatchingUse(cur_class)
        if fqcn isnot 0
            exe "normal! `z"
            echo "import for " . cur_class . " already exists"
            return
        endif
        let fqcn = PhpFindFqcn(cur_class)
        if fqcn is 0
            echo "fully qualified class name was not found"
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
    if fqcn is 0
        return
    endif
    substitute /\%#[[:alnum:]\\]\+/\=fqcn/
    exe restorepos
    " move cursor after fqcn
    call search('\([[:blank:]]*[[:alnum:]\\]\)*', 'ceW')
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

