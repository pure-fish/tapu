#!/usr/bin/env fish
# Main reporter function tests

set --local test_dir (dirname (realpath (status filename)))
set --local project_root (dirname $test_dir)

source $project_root/functions/tap.fish

# Test: tap_reporter function exists
@test "tap_reporter function exists" (
    type -q tap_reporter
    echo $status
)

# Test: tap_reporter is callable
@test "tap_reporter is a valid function" (
    functions tap_reporter >/dev/null 2>&1
    echo $status
)
