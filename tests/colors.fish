#!/usr/bin/env fish
# Color function tests

set --local test_dir (dirname (realpath (status filename)))
set --local project_root (dirname $test_dir)

source $project_root/functions/tap.fish

# Test color functions: output, text preservation, and ANSI codes
set --local colors green red blue yellow magenta dim white

for color in $colors
    set --local func "_color_$color"
    set --local output ($func "test")
    
    @test "$color outputs" -n "$output"
    @test "$color contains text" (string match -q '*test*' "$output"; echo $status) -eq 0
    @test "$color has ANSI codes" (echo "$output" | xxd | grep -q '1b 5b'; echo $status) -eq 0
end
