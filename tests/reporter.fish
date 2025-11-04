#!/usr/bin/env fish
# Main reporter function tests

set --local test_dir (dirname (realpath (status filename)))
set --local project_root (dirname $test_dir)

source $project_root/functions/tap.fish

# Test: tap_reporter function exists and is callable
@test "tap_reporter function exists" -n (functions tap_reporter)

@test "tap_reporter is a function" (functions tap_reporter > /dev/null; echo $status) -eq 0
