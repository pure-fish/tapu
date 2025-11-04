#!/usr/bin/env fish
# Color function tests

set --local test_dir (dirname (realpath (status filename)))
set --local project_root (dirname $test_dir)

source $project_root/functions/tap.fish

# Test: Color functions return output with ANSI codes
@test "color_green outputs" -n (_color_green "test")
@test "color_red outputs" -n (_color_red "test")
@test "color_blue outputs" -n (_color_blue "test")
@test "color_yellow outputs" -n (_color_yellow "test")
@test "color_magenta outputs" -n (_color_magenta "test")
@test "color_dim outputs" -n (_color_dim "test")
@test "color_white outputs" -n (_color_white "test")

# Test: Color outputs contain the input text
@test "color_green contains text" (string match -q '*test*' (_color_green "test"); echo $status) -eq 0
@test "color_red contains text" (string match -q '*test*' (_color_red "test"); echo $status) -eq 0
@test "color_blue contains text" (string match -q '*test*' (_color_blue "test"); echo $status) -eq 0

# Test: Color functions output ANSI codes
@test "color_green has ANSI codes" (_color_green "test" | xxd | grep -q '1b 5b'; echo $status) -eq 0
@test "color_red has ANSI codes" (_color_red "test" | xxd | grep -q '1b 5b'; echo $status) -eq 0
@test "color_blue has ANSI codes" (_color_blue "test" | xxd | grep -q '1b 5b'; echo $status) -eq 0
