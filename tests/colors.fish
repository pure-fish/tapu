#!/usr/bin/env fish
# Color function tests

set --local test_dir (dirname (realpath (status filename)))
set --local project_root (dirname $test_dir)

source $project_root/functions/tap.fish

# Test: Color functions exist and are callable
@test "color_green function exists" -n (functions _color_green)
@test "color_red function exists" -n (functions _color_red)
@test "color_blue function exists" -n (functions _color_blue)
@test "color_yellow function exists" -n (functions _color_yellow)
@test "color_magenta function exists" -n (functions _color_magenta)
@test "color_dim function exists" -n (functions _color_dim)
@test "color_white function exists" -n (functions _color_white)

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
