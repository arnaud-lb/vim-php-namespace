# Goal

vim-php-namespace is a vim script for inserting "use" statements automatically.

## Features

vim-php-namespace automatically inserts the `use ...` statement corresponding to the class under the cursor

## Installation:

### If you don't use tpope/pathogen:

Copy `plugin/phpns.vim` to `~/.vim/plugin/`

### Add mappings:

Add this in `~/.vim/ftplugin/php.vim`: (create the file if necessary)

    imap <buffer> <Leader>u <C-O>:call PhpInsertUse()<CR>
    map <buffer> <Leader>u :call PhpInsertUse()<CR>

The script makes use of tag files. If you don't already use a tag file you may create one with the following command; after having installed ctags-exuberant:

    ctags-exuberant -R --PHP-kinds=+cf

or

    ctags -R --PHP-kinds=+cf

(The [AutoTags](http://www.vim.org/scripts/script.php?script_id=1343) plugin can update the tag file every time a file is modified.)

## Usage:

When the cursor is on a classname, hit `<Leadder>u` to add the corresponding `use` statement. (`<Leader>` is usually the `\` key.)

## Credit:

This a based on an equivalent script for java packages found at http://vim.wikia.com/wiki/Add_Java_import_statements_automatically (in comments).