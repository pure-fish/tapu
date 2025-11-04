#!/usr/bin/env fish
# Main reporter function tests

set --local test_dir (dirname (realpath (status filename)))
set --local project_root (dirname $test_dir)

source $project_root/functions/tap.fish

@test "tap_reporter is callable" (functions tap_reporter > /dev/null; echo $status) -eq 0
