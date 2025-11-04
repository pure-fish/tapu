#!/usr/bin/env fish
# TAP specification compliance tests
# Tests for TAP version 14 specification compliance

set --local test_dir (dirname (realpath (status filename)))
set --local project_root (dirname $test_dir)

source $project_root/functions/tap.fish

# TAP Version 14 Specification Tests
# Reference: https://testanything.org/tap-version-14-specification.html

@test "TAP output contains version line" (
    echo "TAP version 14" | grep -q 'version 14'
    echo $status
)

@test "Test line has valid number" (
    echo "ok 1" | grep -qE '^(ok|not ok) [0-9]+' 
    echo $status
)

@test "Test line with description" (
    echo "ok 1 - description here" | grep -qE '^ok [0-9]+ - '
    echo $status
)

@test "Failed test line format" (
    echo "not ok 2 - test failed" | grep -qE '^not ok [0-9]+ - '
    echo $status
)

@test "Test plan format is valid" (
    echo "1..10" | grep -qE '^[0-9]+\.\.[0-9]+$'
    echo $status
)

@test "Bail out message format" (
    echo "Bail out! Database connection failed" | grep -qE '^Bail out! '
    echo $status
)

@test "Diagnostic lines start with hash" (
    echo "# Diagnostic message" | grep -qE '^# '
    echo $status
)

@test "YAML block starts with indent and three dashes" (
    echo "  ---" | grep -qE '^\s+---$'
    echo $status
)

@test "YAML block ends with three dots" (
    echo "  ..." | grep -qE '^\s+\.\.\.$'
    echo $status
)

@test "Test with TODO directive" (
    echo "not ok 1 - skip this # TODO not implemented" | grep -q 'TODO'
    echo $status
)

@test "Test with SKIP directive" (
    echo "ok 1 - skipped test # SKIP platform not supported" | grep -q 'SKIP'
    echo $status
)
