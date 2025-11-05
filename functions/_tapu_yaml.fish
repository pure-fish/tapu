#!/usr/bin/env fish
# TAP YAML block parser

function _parse_yaml_block
    set --local yaml_lines $argv
    set --local at_line ''
    set --local actual ''
    set --local expected ''
    set --local message ''
    
    for yaml_line in $yaml_lines
        if string match -q -- '    at:*' "$yaml_line"
            set at_line (string replace '    at: ' '' "$yaml_line")
        else if string match -q -- '    actual:*' "$yaml_line"
            set actual (string replace '    actual: ' '' "$yaml_line")
        else if string match -q -- '    expected:*' "$yaml_line"
            set expected (string replace '    expected: ' '' "$yaml_line")
        else if string match -q -- '    message:*' "$yaml_line"
            set message (string replace '    message: ' '' "$yaml_line" | string trim -c '\'"')
        else if string match -q -- '      got:*' "$yaml_line"
            set actual (string replace '      got: ' '' "$yaml_line")
        else if string match -q -- '      expect:*' "$yaml_line"
            set expected (string replace '      expect: ' '' "$yaml_line")
        else if string match -q -- '      wanted:*' "$yaml_line"
            set expected (string replace '      wanted: ' '' "$yaml_line")
        else if string match -q -- '      file:*' "$yaml_line"
            set --local file (string replace '      file: ' '' "$yaml_line")
            test -z "$at_line" && set at_line "$file"
        else if string match -q -- '      line:*' "$yaml_line"
            set --local line_num (string replace '      line: ' '' "$yaml_line")
            test -n "$at_line" && set at_line "$at_line:$line_num"
        end
    end
    
    # Print failure details
    test -n "$message" && _println "$(_color_yellow "  $message")" 2
    test -n "$at_line" && _println "$(_color_dim "  at: $at_line")" 2
    
    if test -n "$expected" -a -n "$actual"
        _println "" 2
        _println "$(_color_red "  Expected: $expected")" 2
        _println "$(_color_red "  Actual:   $actual")" 2
    end
end
