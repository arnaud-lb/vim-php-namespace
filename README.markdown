# Goal

[vim-php-namespace](https://github.com/arnaud-lb/vim-php-namespace) is a vim plugin for inserting "use" statements automatically.

## Features

### Import classes, functions, traits, or enums (add use statements)

Imports the symbol under the cursor by adding the corresponding `use` statement.

To use this feature, add the following mappings in `~/.vimrc`:

    function! IPhpInsertUse()
        call PhpInsertUse()
        call feedkeys('a',  'n')
    endfunction
    autocmd FileType php inoremap <Leader>u <Esc>:call IPhpInsertUse()<CR>
    autocmd FileType php noremap <Leader>u :call PhpInsertUse()<CR>


Then, typing `\u` in normal or insert mode will import the symbol under the cursor.

``` php
<?php
new Response<-- cursor here or on the name; hit \u now to insert the use statement
```

### Make symbol fully qualified

Expands the symbol under the cursor to its fully qualified name.

To use this feature, add the following mappings  in `~/.vimrc`:

    function! IPhpExpandClass()
        call PhpExpandClass()
        call feedkeys('a', 'n')
    endfunction
    autocmd FileType php inoremap <Leader>e <Esc>:call IPhpExpandClass()<CR>
    autocmd FileType php noremap <Leader>e :call PhpExpandClass()<CR>

Then, typing `\e` in normal or insert mode will expand the symbol to its fully qualified name.

``` php
<?php
$this->getMock('RouterInterface<-- cursor here or on the name; type \e now to expand the class name'
```

### Sort existing use statements alphabetically

To use this feature, add the following mappings  in `~/.vimrc`:

    autocmd FileType php inoremap <Leader>s <Esc>:call PhpSortUse()<CR>
    autocmd FileType php noremap <Leader>s :call PhpSortUse()<CR>

Then, hitting `\s` in normal or insert mode will sort use statements.

It is also possible to sort statements automatically after a PhpInsertUse()
by defining the following variable:

    let g:php_namespace_sort_after_insert = 1

## Installation:

### Using [pathogen](https://github.com/tpope/vim-pathogen)

``` sh
git clone git://github.com/arnaud-lb/vim-php-namespace.git ~/.vim/bundle/vim-php-namespace
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

Add to vimrc:

``` vim
Plug 'arnaud-lb/vim-php-namespace'
```

Run command in vim:

``` vim
:PlugInstall
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

The plugin makes use of tag files. If you don't already use a tag file you may create one with the following command; after having installed the `ctags` package:

    ctags -R --PHP-kinds=cfi

#### Traits

[universal-ctags] supports traits natively (with `--php-kinds=cfit`).

If you can't use universal-ctags, the `--regex-php` argument allows to extract traits:

    ctags -R --PHP-kinds=cfi --regex-php="/^[ \t]*trait[ \t]+([a-z0_9_]+)/\1/t,traits/i"

You can also create a `~/.ctags` file with the following contents:

    --regex-php=/^[ \t]*trait[ \t]+([a-z0_9_]+)/\1/t,traits/i

Note that using `--regex-php=` is 10x slower than using universal-ctags.

#### Enums

The `--regex-php` argument can be used to extract enums:

    ctags -R --PHP-kinds=cfi --regex-php="/^[ \t]*enum[ \t]+([a-z0_9_]+)/\1/e,enum/i"

You can also create a `~/.ctags` file with the following contents:

    --regex-php=/^[ \t]*enum[ \t]+([a-z0_9_]+)/\1/e,enum/i

#### Automatically updating tags

The [AutoTags](http://www.vim.org/scripts/script.php?script_id=1343) plugin can update the tags file every time a file is created or modified under vim.

To keep updates fast, AutoTags won't operate if the tags file exceeds 7MB. To avoid exceeding this limit on projects with many dependencies, use a separate tags file for dependencies:

    # dependencies tags file (index only the vendor directory, and save tags in ./tags.vendors)
    ctags -R --PHP-kinds=cfi -f tags.vendors vendor

    # project tags file (index only src, and save tags in ./tags; AutoTags will update this one)
    ctags -R --PHP-kinds=cfi src

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
