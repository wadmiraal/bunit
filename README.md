BUnit
=====

A simple unit testing framework for Bash.

Should I use this?
------------------

Honestly, **probably not** :-). This is just a side project to improve by Bash knowledge (based on a tip by Kent Beck in his *Test Driven Development: By Example*). If you really want a solid framework, I suggest using something like [Bats](https://github.com/sstephenson/bats).

But I really want to give it a try
----------------------------------

Fair enough. Just clone the repo, or copy the `bunit.sh` file. That's it. It contains everything to get you started.

How to write tests
------------------

Bunit doesn't test single files (for now), but tests everything in a given directory (`tests/` by default), which ends with a `.test.sh` extension. Each file should describe a single test suite. This suite can be described using the `describe` function, but only a single call should be made per file.

Test functions should be prefixed with `test_`. They will be executed in sequence.

Example test file:

```
#!/bin/bash

describe "This is a test suite"

test_something()
{
  assert_pass "This will always pass"
}

```

Executing tests
---------------

You can execute tests by simply running `bunit.sh`. You can specify the path to the test directory using the `-t` (or `--tests`) option. Like:

`./bunit.sh -t /path/to/tests`

It will output something like:

```
----- This is a test suite ------
Ran 9 assertions, 8 passed and 1 failed.

Finished.
Ran 9 assertions in total.
	✓ 8 passed
	✗ 1 failed

```

Assertions
----------

The following assertions are available.

- `assert_equals`, usage: `assert_equals $a $b "Assert that a is equal to b"`
- `assert_not_equals`, inverse of the above
- `assert_exit_code`, usage: `assert_exit_code 'ls /home' 0 "Assert the exist code from ls is 0"`
- `assert_pass`, usage: `assert_pass "This assertion always passes"`
- `assert_fail`, inverse of the above


