" Inserts 'use' statements for the class under the cursor
" Makes use of tag files
"
" Maintainer: Arnaud Le Blanc <arnaud.lb at gmail dot com>
" URL: https://github.com/arnaud-lb/vim-php-namespace
"
" This is an adaptation of a script found at http://vim.wikia.com/wiki/Add_Java_import_statements_automatically

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
        exe "ptjump " . cur_class
        let winnr = winnr()
        try
            wincmd P
        catch /.*/
            return
        endtry
        1
        if search('^\s*\%(\%(abstract\|final\)\_s\+\)*\%(class\|interface\|trait\)\_s\+' . cur_class . '\>') > 0
            if search('^\s*namespace\s\+', 'b') > 0
                yank y
            else
                throw "Namespace definition not found!"
            endif
        else
            throw cur_class . ": class not found!"
        endif
        exe winnr . " wincmd w"
        normal! G
        " insert after last use or namespace or <?php
        if search('^use\_s\_[[:alnum:][:blank:]\\]*;', 'be') > 0
            put y
        elseif search('^\s*namespace\_s\_[[:alnum:][:blank:]\\]*[;{]', 'be') > 0
            exe "normal! jO\<Esc>"
            put y
        elseif search('<?\%(php\)\?', 'be') > 0
            exe "normal! jO\<Esc>"
            put y
        else
            1
            put y
        endif
        substitute/^\s*namespace/use/g
        substitute/\s\+/ /g
        substitute/\s*[{;]\?\s*$/;/
        exe "normal! 2ER\\" . cur_class . ";\<Esc>lD"
    catch /.*/
        echoerr v:exception
    finally
        " wipe preview window (from buffer list)
        silent! wincmd P
        if &previewwindow
            bwipeout
        endif
        exe "normal! `z"
    endtry
endfunction

