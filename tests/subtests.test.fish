#!/usr/bin/env fish
# TAP specification subtest tests
# Reference: https://testanything.org/tap-version-14-specification.html#subtests

source (status dirname)/../functions/_tapu_subtests.fish
@echo (set_color blue)(status filename)(set_color normal)


# Test bare subtest
@test "bare subtest with indented test points" (
    printf "TAP version 14\n    ok 1 - subtest test point\n    1..1\nok 1 - subtest passing\n1..1\n" | tapu >/dev/null 2>&1
    echo $status
) -eq 0

# Test commented subtest with name
@test "commented subtest with name" (
    printf "TAP version 14\nok 1 - first test\n# Subtest: nested\n    1..1\n    ok 1 - in the subtest\nok 2 - nested\n1..2\n" | tapu >/dev/null 2>&1
    echo $status
) -eq 0

# Test commented subtest without name
@test "commented subtest without name" (
    printf "TAP version 14\n# Subtest\n    ok 1 - name is optional\n    1..1\nok 4\n1..1\n" | tapu >/dev/null 2>&1
    echo $status
) -eq 0

# Test nested subtests
@test "nested subtests with 8-space indentation" (
    printf "TAP version 14\n        ok 1 - nested twice\n        1..1\n    ok 1 - nested parent\n    1..1\nok 1 - double nest passing\n1..1\n" | tapu >/dev/null 2>&1
    echo $status
) -eq 0

# Test subtest with failing test
@test "subtest with failing test points" (
    printf "# Subtest: failing\n    ok 1\n    not ok 2\n    1..2\nnot ok 1 - failing\n1..1\n" | tapu >/dev/null 2>&1
    echo $status
) -eq 1

# Test subtest with YAML diagnostics
@test "subtest with YAML diagnostics" (
    printf "# Subtest: yaml\n    not ok 1\n      ---\n      message: failed\n      ...\n    1..1\nnot ok 1 - yaml\n1..1\n" | tapu >/dev/null 2>&1
    echo $status
) -eq 1

# Test empty subtest
@test "empty subtest with 1..0 plan" (
    printf "# Subtest: empty\n    1..0\nok 1 - empty\n1..1\n" | tapu >/dev/null 2>&1
    echo $status
) -eq 0
