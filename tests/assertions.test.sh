#!/bin/bash

describe "Test assertions."

test_assert_equals()
{
    assert_equals "A" "A" "Asserting 2 identical strings are equal should not fail."
    assert_equals 1 1 "Asserting 2 identical integers are equal should not fail."
}

function test_assert_not_equals
{
    assert_not_equals "A" "B" "Asserting 2 different strings are not equal should not fail."
    assert_not_equals 1 2 "Asserting 2 different integers are not equal should not fail."
}

function test_assert_exit_code()
{
    assert_exit_code "ls /" 0 "Asserting a successful command exits with 0 should not fail."
    assert_exit_code "ls ___does_not_exist___" 2 "Asserting a failing ls command exits with 2 should not fail."
}

function test_assert_pass () {
    assert_pass "This always passes."
}

