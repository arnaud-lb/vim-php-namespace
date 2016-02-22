# Goal

vim-php-namespace is a vim plugin for inserting "use" statements automatically.

## Features

### Import classes (add use statements)

Automatically adds the corresponding `use` statement for the class under the cursor.

To use this feature, add the following mappings in `~/.vimrc`:

    function! IPhpInsertUse()
        call PhpInsertUse()
        call feedkeys('a',  'n')
    endfunction
    autocmd FileType php inoremap <Leader>u <Esc>:call IPhpInsertUse()<CR>
    autocmd FileType php noremap <Leader>u :call PhpInsertUse()<CR>


Then, hitting `\u` in normal or insert mode will import the class under the cursor.

``` php
<?php
new Response<-- cursor here or on the name; hit \u now to insert the use statement
```

### Make class names fully qualified

Expands the class name under the cursor to its fully qualified name.

To use this feature, add the following mappings  in `~/.vimrc`:

    function! IPhpExpandClass()
        call PhpExpandClass()
        call feedkeys('a', 'n')
    endfunction
    autocmd FileType php inoremap <Leader>e <Esc>:call IPhpExpandClass()<CR>
    autocmd FileType php noremap <Leader>e :call PhpExpandClass()<CR>

Then, hitting `\e` in normal or insert mode will expand the class name to a fully qualified name.

``` php
<?php
$this->getMock('RouterInterface<-- cursor here or on the name; hit \e now to expand the class name'
```

### Sort existing use statements alphabetically

If you do not know how to organize use statements, (or anything else, for that
matter), the alphabetical order might be a sensible choice, because it makes
finding what you are looking for easier, and reduces the risk for conflicts :
if everyone adds new things at the same line, conflicts are guaranteed.

This vim plugin defines a `PhpSortUse()` you may use in your mappings:

    autocmd FileType php inoremap <Leader>s <Esc>:call PhpSortUse()<CR>
    autocmd FileType php noremap <Leader>s :call PhpSortUse()<CR>

## Installation:

### Using [pathogen](https://github.com/tpope/vim-pathogen)

``` sh
git clone git://github.com/arnaud-lb/vim-php-namespace.git ~/.vim/bundle/vim-php-namespace
```

### Using [vundle](https://github.com/gmarik/vundle)

Add to vimrc:

``` vim
Bundle 'arnaud-lb/vim-php-namespace'
```

Run command in vim:

``` vim
:BundleInstall
```

### Manual installation

Download and copy `plugin/phpns.vim` to `~/.vim/plugin/`

## Post installation

### Generate a tag file

The plugin makes use of tag files. If you don't already use a tag file you may create one with the following command; after having installed the `ctags` or `ctags-exuberant` package:

    ctags-exuberant -R --PHP-kinds=+cf

or

    ctags -R --PHP-kinds=+cf

#### Traits

ctags doesn't indexes [traits](http://php.net/traits) by default, you have to add a `--regex-php` option to index them:

    ctags -R --PHP-kinds=+cf --regex-php=/^[ \t]*trait[ \t]+([a-z0_9_]+)/\1/t,traits/i

Alternatively, create a `~/.ctags` file with the following contents:

    --regex-php=/^[ \t]*trait[ \t]+([a-z0_9_]+)/\1/t,traits/i

You could also use [this patched version of ctags](https://github.com/shawncplus/phpcomplete.vim/wiki/Patched-ctags)

#### Automatically updating tags

The [AutoTags](http://www.vim.org/scripts/script.php?script_id=1343) plugin can update the tags file every time a file is created or modified under vim.

To keep updates fast, AutoTags won't operate if the tags file exceeds 7MB. To avoid exceeding this limit on projects with many dependencies, use a separate tags file for dependencies:

    # dependencies tags file (index only the vendor directory, and save tags in ./tags.vendors)
    ctags -R --PHP-kinds=+cf -f tags.vendors vendor

    # project tags file (index only src, and save tags in ./tags; AutoTags will update this one)
    ctags -R --PHP-kinds=+cf src

Do not forget to load both files in vim:

    " ~/.vimrc
    set tags+=tags,tags.vendors

### Key mappings

See [Features](#features) section for adding key mappings.

The `<Leader>` key usually is `\`.

## Credits:

 * Arnaud Le Blanc
 * [Contributors](https://github.com/arnaud-lb/vim-php-namespace/graphs/contributors)

This was originally based on a similar script for java packages found at http://vim.wikia.com/wiki/Add_Java_import_statements_automatically (in comments).
