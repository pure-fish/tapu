#!/usr/bin/env fish
# Formatting helper functions for tapu

function _unescape_tap
    set --local input "$argv[1]"
    set input (string replace -a '\\\\' '\x00' -- "$input")
    set input (string replace -a '\\#' '#' -- "$input")
    echo (string replace -a '\x00' '\\' -- "$input")
end

function _println
    set --local input "$argv[1]"
    set --local indent_level (set -q argv[2] && echo $argv[2] || echo 0)
    set --local indent_str ''
    for i in (seq 1 $indent_level)
        set indent_str "$indent_str  "
    end
    
    if test -z "$input"
        echo
    else
        echo "$input" | while read -l line
            echo "$indent_str$line"
        end
    end
end

function _format_ms
    set --local ms $argv[1]
    test $ms -lt 1000 && echo $ms"ms" && return
    
    set --local seconds (math "floor($ms / 1000)")
    set --local minutes (math "floor($seconds / 60)")
    set --local hours (math "floor($minutes / 60)")
    
    if test $hours -gt 0
        set minutes (math "$minutes % 60")
        set seconds (math "$seconds % 60")
        echo "{$hours}h {$minutes}m {$seconds}s"
    else if test "$minutes" -gt 0
        set seconds (math "$seconds % 60")
        echo "{$minutes}m {$seconds}s"
    else
        echo "{$seconds}s"
    end
end

function _highlight_diff
    set --local actual "$argv[1]"
    set --local expected "$argv[2]"
    
    if test "$actual" = "$expected"
        echo "Actual/Expected: $actual"; return
    end
    
    echo -n "Actual:   "
    set --local actual_len (string length -- "$actual")
    set --local expected_len (string length -- "$expected")
    
    for i in (seq 1 $actual_len)
        set --local actual_char (string sub -s $i -l 1 -- "$actual")
        set --local expected_char (string sub -s $i -l 1 -- "$expected")
        if test "$actual_char" != "$expected_char"
            set_color -b red; echo -n "$actual_char"; set_color normal
        else
            echo -n "$actual_char"
        end
    end
    echo
    
    echo -n "Expected: "
    for i in (seq 1 $expected_len)
        set --local actual_char (string sub -s $i -l 1 -- "$actual")
        set --local expected_char (string sub -s $i -l 1 -- "$expected")
        if test "$actual_char" != "$expected_char"
            set_color -b green; echo -n "$expected_char"; set_color normal
        else
            echo -n "$expected_char"
        end
    end
    echo
end
