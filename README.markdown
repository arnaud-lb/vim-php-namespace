# Goal

vim-php-namespace is a vim script for inserting "use" statements automatically.

## Features

### Import classes (add use statements)

Automatically adds the corresponding `use` statement for the class under the cursor.

To use this feature, add the following mappings in `~/.vimrc`:

    inoremap <Leader>u <C-O>:call PhpInsertUse()<CR>
    noremap <Leader>u :call PhpInsertUse()<CR>

Then, hitting `\u` in normal or insert mode will import the class under the cursor.

``` php
<?php
new Response<-- cursor here or on the name; hit \u now to insert the use statement
```

### Make class names fully qualified

Expands the class name under the cursor to its fully qualified name.

To use this feature, add the following mappings  in `~/.vimrc`:

    inoremap <Leader>e <C-O>:call PhpExpandClass()<CR>
    noremap <Leader>e :call PhpExpandClass()<CR>

Then, hitting `\e` in normal or insert mode will expand the class name to a fully qualified name.

``` php
<?php
$this->getMock('RouterInterface<-- cursor here or on the name; hit \e now to expand the class name'
```

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

The [AutoTags](http://www.vim.org/scripts/script.php?script_id=1343) plugin can update the tag file every time you modify or create a file under vim.

### Key mappings

See [Features](#features) section for adding key mappings.

The `<Leader>` key usually is `\`.

## Credits:

 * Arnaud Le Blanc
 * [Contributors](https://github.com/arnaud-lb/vim-php-namespace/graphs/contributors)

This is based on an equivalent script for java packages found at http://vim.wikia.com/wiki/Add_Java_import_statements_automatically (in comments).
