#!/usr/bin/env fish
# Color function tests

set --local test_dir (dirname (realpath (status filename)))
set --local project_root (dirname $test_dir)

source $project_root/functions/tap.fish

# Test: Color functions exist
@test "color_green function exists" (
    type -q _color_green
    echo $status
)

@test "color_red function exists" (
    type -q _color_red
    echo $status
)

@test "color_blue function exists" (
    type -q _color_blue
    echo $status
)

@test "color_yellow function exists" (
    type -q _color_yellow
    echo $status
)

@test "color_magenta function exists" (
    type -q _color_magenta
    echo $status
)

@test "color_dim function exists" (
    type -q _color_dim
    echo $status
)

@test "color_white function exists" (
    type -q _color_white
    echo $status
)

# Test: Color functions output text
@test "color_green outputs text" (
    set --local output (_color_green "test")
    test -n "$output"
    echo $status
)

@test "color_red outputs text" (
    set --local output (_color_red "test")
    test -n "$output"
    echo $status
)

@test "color_blue outputs text" (
    set --local output (_color_blue "test")
    test -n "$output"
    echo $status
)
