#!/usr/bin/env fish
# Color function tests

source (status dirname)/../functions/_tapu_colors.fish
@echo (set_color blue)(status filename)(set_color normal)

# Test color functions: output, text preservation, and ANSI codes
set --local colors green red blue yellow magenta dim white

for color in $colors
    set --local func "_color_$color"
    set --local output ($func "test")
    
    @test "$color outputs" -n "$output"
    @test "$color contains text" (string match -q '*test*' "$output"; echo $status) -eq 0
    @test "$color has ANSI codes" (printf "%s" "$output" | xxd | grep -q '1b5b'; echo $status) -eq 0
end
