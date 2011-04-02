# Goal

vim-php-namespace is a helper script for inserting "use" statements automatically.

## Installation:

 * Copy `phpns.vim` to `~/.vim/plugin/`
 * Add this in `~/.vim/ftplugin/php.vim`:

        imap <buffer> <F5> <ESC>:call PhpInsertUse()<CR>
        map <buffer> <F5> :call PhpInsertUse()<CR>

The script makes use of tag files. If you don't already use a tag file you may create one with the following command; after having installed ctags-exuberant:

    ctags-exuberant -R --PHP-kinds=+cf

## Usage:

When the cursor is on a classname, hit F5 to add the corresponding `use` statement.

