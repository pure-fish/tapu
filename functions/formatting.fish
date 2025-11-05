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
    else if test $minutes -gt 0
        set seconds (math "$seconds % 60")
        echo "{$minutes}m {$seconds}s"
    else
        echo "{$seconds}s"
    end
end
