#!/usr/bin/env fish
# YAML diagnostics display tests

@echo (set_color blue)(status filename)(set_color normal)

# Test that YAML diagnostics are shown for failed tests
@test "YAML diagnostics displayed for failures" (
    printf "not ok 1 fail\n  ---\n    expected: foo\n    actual: bar\n    at: test.fish:10\n  ...\n1..1\n" \
        | ./functions/tapu.fish 2>&1 \
        | sed -r 's/\x1b\[[0-9;]*m|\x1b\(B//g' \
        | grep -q "at test.fish:10"
    echo $status
) -eq 0

@test "YAML diagnostics show expected value" (
    printf "not ok 1 fail\n  ---\n    expected: foo\n    actual: bar\n  ...\n1..1\n" \
        | ./functions/tapu.fish 2>&1 \
        | grep -q "foo"
    echo $status
) -eq 0

@test "YAML diagnostics show actual value" (
    printf "not ok 1 fail\n  ---\n    expected: foo\n    actual: bar\n  ...\n1..1\n" \
        | ./functions/tapu.fish 2>&1 \
        | grep -q "bar"
    echo $status
) -eq 0

@test "YAML diagnostics with operator field" (
    printf "not ok 1 fail\n  ---\n    operator: -eq\n    expected: 0\n    actual: 1\n  ...\n1..1\n" \
        | ./functions/tapu.fish 2>&1 \
        | sed -r 's/\x1b\[[0-9;]*m|\x1b\(B//g' \
        | grep -q "10"
    echo $status
) -eq 0

@test "YAML diagnostics with message field" (
    printf "not ok 1 fail\n  ---\n    message: 'test failed'\n    expected: true\n    actual: false\n  ...\n1..1\n" \
        | ./functions/tapu.fish 2>&1 \
        | sed -r 's/\x1b\[[0-9;]*m|\x1b\(B//g' \
        | grep -q "falsetrue"
    echo $status
) -eq 0

@test "YAML diagnostics with file and line fields" (
    printf "not ok 1 fail\n  ---\n      file: mytest.fish\n      line: 42\n    expected: 1\n    actual: 0\n  ...\n1..1\n" \
        | ./functions/tapu.fish 2>&1 \
        | sed -r 's/\x1b\[[0-9;]*m|\x1b\(B//g' \
        | grep -q "at mytest.fish:42"
    echo $status
) -eq 0

@test "YAML diagnostics not shown for passing tests" (
    printf "ok 1 pass\n  ---\n    note: this should not appear\n  ...\n1..1\n" \
        | ./functions/tapu.fish 2>&1 \
        | grep -q "this should not appear"
    echo $status
) -eq 1

@test "YAML blocks work after subtests for failing tests" (
    printf "not ok 1 parent\n    ok 1 child\n  ---\n    expected: pass\n    actual: fail\n  ...\n1..1\n" \
        | ./functions/tapu.fish 2>&1 \
        | sed -r 's/\x1b\[[0-9;]*m|\x1b\(B//g' \
        | grep -q "failpass"
    echo $status
) -eq 0
