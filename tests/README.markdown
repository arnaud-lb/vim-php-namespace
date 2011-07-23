# Tests

The Makefile and other vim scripts in this directory are modified version of vim's own test scripts.

## How to run tests:

    make

## How to create a test:

    make newtest from=test-basic-1 to=new-test-name

Then edit `new-test-name.in`, `new-test-name.ok` and any file in `new-test-name.fixtures` as needed.

