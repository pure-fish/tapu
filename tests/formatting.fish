#!/usr/bin/env fish
# Formatting function tests

set --local test_dir (dirname (realpath (status filename)))
set --local project_root (dirname $test_dir)

source $project_root/functions/tap.fish

@test "println outputs text" -n (_println "test message")

@test "format_ms converts milliseconds" (string match -q "*s" (_format_ms 1000); echo $status) -eq 0

@test "format_ms handles zero" -n (_format_ms 0)

@test "format_ms outputs milliseconds for small values" (string match -q "*ms" (_format_ms 500); echo $status) -eq 0

@test "highlight_diff outputs" -n (_highlight_diff "actual" "expected")
