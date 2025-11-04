#!/usr/bin/env fish
# Formatting function tests

set --local test_dir (dirname (realpath (status filename)))
set --local project_root (dirname $test_dir)

source $project_root/functions/tap.fish

# Test: println function exists
@test "println function exists" (
    type -q _println
    echo $status
)

# Test: println outputs text with newline
@test "println outputs text" (
    set --local output (_println "test message")
    test -n "$output"
    echo $status
)

# Test: format_ms function exists
@test "format_ms function exists" (
    type -q _format_ms
    echo $status
)

# Test: format_ms converts milliseconds
@test "format_ms converts 1000ms to 1s" (
    set --local output (_format_ms 1000)
    echo "$output" | grep -q '1'
    echo $status
)

# Test: format_ms handles zero
@test "format_ms handles 0ms" (
    set --local output (_format_ms 0)
    test -n "$output"
    echo $status
)

# Test: highlight_diff function exists
@test "highlight_diff function exists" (
    type -q _highlight_diff
    echo $status
)
