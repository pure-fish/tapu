#!/usr/bin/env fish
# TAP specification escaping tests
# Reference: https://testanything.org/tap-version-14-specification.html#escaping

set --local project_root (dirname (dirname (realpath (status filename))))
source $project_root/functions/_tapu_escaping.fish
source $project_root/functions/tapu.fish
@echo (_color_blue (status filename))


# Test escaping in descriptions
@test "unescaped hash in description" (
    printf "TAP version 14\nok 1 - hello # world\n1..1\n" | tapu 2>&1 | grep -q "hello # world"
    echo $status
) -eq 0

@test "escaped hash in description" (
    printf "TAP version 14\nok 1 - hello \\\\# world\n1..1\n" | tapu 2>&1 | grep -q "hello # world"
    echo $status
) -eq 0

@test "escaped backslash in description" (
    printf "TAP version 14\nok 1 - hello \\\\\\\\ world\n1..1\n" | tapu 2>&1 | grep -q "hello \\\\ world"
    echo $status
) -eq 0

@test "escaped hash should not be directive delimiter" (
    printf "TAP version 14\nok 1 - test \\\\# TODO not a todo\n1..1\n" | tapu 2>&1 | grep -qv "TODO"
    echo $status
) -eq 0

@test "multiple escaped backslashes" (
    printf "TAP version 14\nok 1 - test \\\\\\\\\\\\\\\\\\\\\\\\# escaped\n1..1\n" | tapu 2>&1 | grep -q "test \\\\\\\\\\\\# escaped"
    echo $status
) -eq 0

# Test escaping in TODO/SKIP reasons
@test "escaped hash in TODO reason" (
    printf "TAP version 14\nok 1 - test # TODO fix \\\\# character\n1..1\n" | tapu 2>&1 | grep -q "# character"
    echo $status
) -eq 0

@test "escaped backslash in SKIP reason" (
    printf "TAP version 14\nok 1 - test # SKIP no \\\\\\\\ support\n1..1\n" | tapu 2>&1 | grep -q "\\\\ support"
    echo $status
) -eq 0

# Test escaping in plan reasons
@test "escaped hash in plan reason" (
    printf "TAP version 14\n1..0 # skip \\\\# not supported\n" | tapu 2>&1 | grep -q "# not supported"
    echo $status
) -eq 0

# Test escaping in bailout messages
@test "escaped hash in bailout message" (
    printf "Bail out! \\\\# and \\\\\\\\ not supported\n" | tapu 2>&1 | grep -q "# and \\\\ not supported"
    echo $status
) -eq 0

# Test examples from specification
@test "spec example: hello # todo" (
    printf "TAP version 14\nok 1 - hello # todo\n1..1\n" | tapu 2>&1 | grep -q "TODO"
    echo $status
) -eq 0

@test "spec example: hello \\# todo" (
    printf "TAP version 14\nok 2 - hello \\\\# todo\n1..1\n" | tapu 2>&1 | grep -qv "TODO"
    echo $status
) -eq 0

@test "spec example: URL with hash" (
    printf "TAP version 14\nok 2 not skipped: https://example.com/page.html\\\\#skip is a url\n1..1\n" | tapu 2>&1 | grep -qv "SKIP"
    echo $status
) -eq 0
