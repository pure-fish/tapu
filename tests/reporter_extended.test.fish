#!/usr/bin/env fish
# Extended reporter tests for edge cases and TAP 14 compliance

source (status dirname)/../functions/tapu.fish
@echo (set_color blue)(status filename)(set_color normal)


# Test comment handling
@test "file header comments are displayed" (
    printf "TAP version 14\n# My Test Suite\nok 1\n1..1\n" | tapu 2>&1 | grep -q "My Test Suite"
    echo $status
) -eq 0

@test "fishtape summary comments are filtered" (
    printf "TAP version 14\nok 1\n1..1\n# pass 1\n# ok\n" | tapu 2>&1 | grep -qv "^  pass 1"
    echo $status
) -eq 0

@test "multiple file headers shown separately" (
    printf "TAP version 14\n# Suite 1\nok 1\n# Suite 2\nok 2\n1..2\n" | tapu 2>&1 | grep -q "Suite 1"
    set -l status1 $status
    printf "TAP version 14\n# Suite 1\nok 1\n# Suite 2\nok 2\n1..2\n" | tapu 2>&1 | grep -q "Suite 2"
    set -l status2 $status
    test $status1 -eq 0 -a $status2 -eq 0
    echo $status
) -eq 0


# Test summary formatting
@test "summary omits zero skip count" (
    printf "TAP version 14\nok 1\nok 2\n1..2\n" | tapu 2>&1 | grep "passed.*failed" | grep -qv "skipped:"
    echo $status
) -eq 0

@test "summary omits zero todo count" (
    printf "TAP version 14\nok 1\nok 2\n1..2\n" | tapu 2>&1 | grep "passed.*failed" | grep -qv "todo:"
    echo $status
) -eq 0

@test "summary includes nonzero skip count" (
    printf "TAP version 14\nok 1 # SKIP\nok 2\n1..2\n" | tapu 2>&1 | grep -q "skipped: 1"
    echo $status
) -eq 0

@test "summary includes nonzero todo count" (
    printf "TAP version 14\nok 1 # TODO\nok 2\n1..2\n" | tapu 2>&1 | grep -q "todo: 1"
    echo $status
) -eq 0


# Test indentation
@test "file headers have 2-space indent" (
    printf "TAP version 14\n# test\nok 1\n1..1\n" | tapu 2>&1 | grep -q "^  test"
    echo $status
) -eq 0

@test "test results have 4-space indent" (
    printf "TAP version 14\nok 1 - my test\n1..1\n" | tapu 2>&1 | grep -q "^    .*my test"
    echo $status
) -eq 0


# Test directive parsing
@test "TODO is case insensitive" (
    printf "TAP version 14\nok 1 # tOdO\n1..1\n" | tapu 2>&1 | grep -q "todo: 1"
    echo $status
) -eq 0

@test "SKIP is case insensitive" (
    printf "TAP version 14\nok 1 # SkIp\n1..1\n" | tapu 2>&1 | grep -q "skipped: 1"
    echo $status
) -eq 0

@test "TODO with extra characters after directive" (
    printf "TAP version 14\nok 1 # TODO: fix this\n1..1\n" | tapu 2>&1 | grep -q "todo: 1"
    echo $status
) -eq 0

@test "SKIP with extra characters after directive" (
    printf "TAP version 14\nok 1 # SKIPPED: not ready\n1..1\n" | tapu 2>&1 | grep -q "skipped: 1"
    echo $status
) -eq 0


# Test description handling
@test "description with leading dash" (
    printf "TAP version 14\nok 1 - test name\n1..1\n" | tapu 2>&1 | grep -q "test name"
    echo $status
) -eq 0

@test "description without leading dash" (
    printf "TAP version 14\nok 1 test name\n1..1\n" | tapu 2>&1 | grep -q "test name"
    echo $status
) -eq 0

@test "empty description handled" (
    printf "TAP version 14\nok 1\n1..1\n" | tapu 2>&1 | grep -q "✔"
    echo $status
) -eq 0


# Test plan handling
@test "plan at start" (
    printf "TAP version 14\n1..2\nok 1\nok 2\n" | tapu 2>&1 | grep -q "passed: 2"
    echo $status
) -eq 0

@test "plan at end" (
    printf "TAP version 14\nok 1\nok 2\n1..2\n" | tapu 2>&1 | grep -q "passed: 2"
    echo $status
) -eq 0

@test "1..0 plan shows skip message" (
    printf "TAP version 14\n1..0 # skip no tests\n" | tapu 2>&1 | grep -q "Skipped:"
    echo $status
) -eq 0


# Test mixed test results
@test "passing and failing tests" (
    printf "TAP version 14\nok 1\nnot ok 2\n1..2\n" | tapu 2>&1 | grep -q "passed: 1.*failed: 1"
    echo $status
) -eq 0

@test "passing TODO test counted as pass" (
    printf "TAP version 14\nok 1 # TODO\n1..1\n" | tapu 2>&1 | grep -q "passed: 1"
    echo $status
) -eq 0

@test "failing TODO test not counted as failure" (
    printf "TAP version 14\nnot ok 1 # TODO\n1..1\n" | tapu 2>&1 | grep -q "passed: 0.*failed: 0"
    echo $status
) -eq 0


# Test exit codes
@test "exit 0 on all pass" (
    printf "TAP version 14\nok 1\nok 2\n1..2\n" | tapu >/dev/null 2>&1
    test $status -eq 0
    echo $status
) -eq 0

@test "exit 1 on any failure" (
    printf "TAP version 14\nok 1\nnot ok 2\n1..2\n" | tapu >/dev/null 2>&1
    test $status -eq 1
    echo $status
) -eq 0

@test "exit 1 on bailout" (
    printf "Bail out! test\n" | tapu >/dev/null 2>&1
    test $status -eq 1
    echo $status
) -eq 0


# Test TAP version handling
@test "TAP version 13 accepted" (
    printf "TAP version 13\nok 1\n1..1\n" | tapu 2>&1 | grep -q "passed: 1"
    echo $status
) -eq 0

@test "TAP version 14 accepted" (
    printf "TAP version 14\nok 1\n1..1\n" | tapu 2>&1 | grep -q "passed: 1"
    echo $status
) -eq 0


# Test test point numbers
@test "test without number" (
    printf "TAP version 14\nok\n1..1\n" | tapu 2>&1 | grep -q "✔"
    echo $status
) -eq 0

@test "test with number" (
    printf "TAP version 14\nok 1\n1..1\n" | tapu 2>&1 | grep -q "✔"
    echo $status
) -eq 0


# Test YAML diagnostics (basic - just ensure they don't break parsing)
@test "YAML block doesn't break parsing" (
    printf "TAP version 14\nnot ok 1\n  ---\n  message: failed\n  ...\n1..1\n" | tapu 2>&1 | grep -q "failed: 1"
    echo $status
) -eq 0


# Test hash in description (non-directive)
@test "hash in description without TODO/SKIP" (
    printf "TAP version 14\nok 1 - test #1 of suite\n1..1\n" | tapu 2>&1 | grep -q "test #1 of suite"
    echo $status
) -eq 0

@test "hash without space before is kept in description" (
    printf "TAP version 14\nok 1 - test#value\n1..1\n" | tapu 2>&1 | grep -q "test#value"
    echo $status
) -eq 0
