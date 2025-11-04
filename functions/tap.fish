#!/usr/bin/env fish
# TAP (Test Anything Protocol) Reporter for Fish Shell
# A pure fish implementation similar to tap-diff/tap-mocha-reporter
# Formats TAP output with colors, symbols, and timing information

set --local --export INDENT '  '
set --local --export TICK '✔'
set --local --export CROSS '✖'

# Color helpers (compatible with fish set_color)
function _color_green
    set_color green
    echo -n $argv
    set_color normal
end

function _color_red
    set_color red
    echo -n $argv
    set_color normal
end

function _color_blue
    set_color blue
    echo -n $argv
    set_color normal
end

function _color_yellow
    set_color yellow
    echo -n $argv
    set_color normal
end

function _color_magenta
    set_color magenta
    echo -n $argv
    set_color normal
end

function _color_dim
    set_color brblack
    echo -n $argv
    set_color normal
end

function _color_white
    set_color white
    echo -n $argv
    set_color normal
end

# Print with indentation
function _println
    set --local input "$argv[1]"
    set --local indent_level 0
    if set -q argv[2]
        set indent_level $argv[2]
    end
    
    set --local indent_str ''
    for i in (seq 1 $indent_level)
        set indent_str "$indent_str$INDENT"
    end
    
    if test -z "$input"
        echo
    else
        echo "$input" | while read -l line
            echo "$indent_str$line"
        end
    end
end

# Format milliseconds to human readable
function _format_ms
    set --local ms $argv[1]
    
    if test $ms -lt 1000
        echo "{$ms}ms"
        return
    end
    
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

# Highlight differences between two strings
function _highlight_diff
    set --local actual "$argv[1]"
    set --local expected "$argv[2]"
    
    # If strings are identical, just return them
    if test "$actual" = "$expected"
        echo "Actual/Expected: $actual"
        return
    end
    
    # Show actual with red background for differences
    echo -n "Actual:   "
    set --local actual_len (string length -- "$actual")
    set --local expected_len (string length -- "$expected")
    set --local max_len (math "max($actual_len, $expected_len)")
    
    for i in (seq 1 $actual_len)
        set --local actual_char (string sub -s $i -l 1 -- "$actual")
        set --local expected_char (string sub -s $i -l 1 -- "$expected")
        
        if test "$actual_char" != "$expected_char"
            set_color -b red
            echo -n "$actual_char"
            set_color normal
        else
            echo -n "$actual_char"
        end
    end
    echo
    
    # Show expected with green background for differences
    echo -n "Expected: "
    for i in (seq 1 $expected_len)
        set --local actual_char (string sub -s $i -l 1 -- "$actual")
        set --local expected_char (string sub -s $i -l 1 -- "$expected")
        
        if test "$actual_char" != "$expected_char"
            set_color -b green
            echo -n "$expected_char"
            set_color normal
        else
            echo -n "$expected_char"
        end
    end
    echo
end

# Main TAP parser
function tap_reporter
    set --local started_at (date +%s%3N)
    set --local test_count 0
    set --local pass_count 0
    set --local fail_count 0
    set --local skip_count 0
    set --local todo_count 0
    set --local planned_tests 0
    set --local current_test ''
    set --local in_yaml false
    set --local yaml_lines
    set --local exit_code 0
    set --local bailed_out false
    
    # Read TAP input line by line
    while read -l line
        # Handle Bail out!
        if string match -q -r -i '^Bail out!' "$line"
            set --local reason (string replace -r -i '^Bail out!\s*' '' "$line" | string trim)
            # Unescape \# and \\
            set reason (string replace -a '\\#' '#' "$reason")
            set reason (string replace -a '\\\\' '\\' "$reason")
            _println
            _println "$(_color_red "Bail out!") $reason"
            _println
            set bailed_out true
            set exit_code 1
            break
        end
        
        # Handle YAML blocks (diagnostic info)
        if string match -q '  ---' "$line"
            set in_yaml true
            set yaml_lines
            continue
        else if string match -q '  ...' "$line"
            set in_yaml false
            
            # Parse YAML for failure details (support common field names)
            set --local at_line ''
            set --local actual ''
            set --local expected ''
            set --local message ''
            set --local severity ''
            
            for yaml_line in $yaml_lines
                # Handle various YAML field names
                if string match -q '    at:*' "$yaml_line"
                    set at_line (string replace '    at: ' '' "$yaml_line")
                else if string match -q '    actual:*' "$yaml_line"
                    set actual (string replace '    actual: ' '' "$yaml_line")
                else if string match -q '    expected:*' "$yaml_line"
                    set expected (string replace '    expected: ' '' "$yaml_line")
                else if string match -q '    message:*' "$yaml_line"
                    set message (string replace '    message: ' '' "$yaml_line" | string trim -c '\'"')
                else if string match -q '    severity:*' "$yaml_line"
                    set severity (string replace '    severity: ' '' "$yaml_line")
                # Also support 'got' and 'want' or 'wanted'
                else if string match -q '      got:*' "$yaml_line"
                    set actual (string replace '      got: ' '' "$yaml_line")
                else if string match -q '      expect:*' "$yaml_line"
                    set expected (string replace '      expect: ' '' "$yaml_line")
                else if string match -q '      wanted:*' "$yaml_line"
                    set expected (string replace '      wanted: ' '' "$yaml_line")
                # Handle file/line in 'at' block
                else if string match -q '      file:*' "$yaml_line"
                    set --local file (string replace '      file: ' '' "$yaml_line")
                    if test -z "$at_line"
                        set at_line "$file"
                    end
                else if string match -q '      line:*' "$yaml_line"
                    set --local line_num (string replace '      line: ' '' "$yaml_line")
                    if test -n "$at_line"
                        set at_line "$at_line:$line_num"
                    end
                end
            end
            
            # Print failure details with message if available
            if test -n "$message"
                _println "$(_color_yellow "  $message")" 2
            end
            
            if test -n "$at_line"
                _println "$(_color_dim "  at: $at_line")" 2
            end
            
            if test -n "$expected" -a -n "$actual"
                _println "" 2
                _highlight_diff "$actual" "$expected" | while read -l diff_line
                    _println "$diff_line" 3
                end
            end
            continue
        end
        
        if test $in_yaml = true
            set -a yaml_lines "$line"
            continue
        end
        
        # Parse TAP version
        if string match -q -r '^TAP version' "$line"
            # Just skip version line, don't display it
            continue
        end
        
        # Parse TAP comment (test name or subtest marker)
        if string match -q '# *' "$line"
            set current_test (string replace '# ' '' "$line" | string trim)
            
            # Skip summary comments (fishtape adds these)
            if string match -q 'tests *' "$current_test"; or \
               string match -q 'pass *' "$current_test"; or \
               string match -q 'fail *' "$current_test"; or \
               string match -q 'ok' "$current_test"
                continue
            end
            
            # Check if it's a Subtest marker
            if string match -q 'Subtest:*' "$current_test"; or \
               string match -q 'Subtest' "$current_test"
                # For now, just print it as a section header
                set current_test (string replace 'Subtest: ' '' "$current_test" | string replace 'Subtest' '' | string trim)
                if test -n "$current_test"
                    _println
                    _println "$(_color_blue "$current_test")" 1
                end
                continue
            end
            
            _println
            _println "$(_color_blue "$current_test")" 1
            continue
        end
        
        # Parse TAP ok/not ok lines
        if string match -q -r '^ok' "$line"; or string match -q -r '^not ok' "$line"
            set test_count (math "$test_count + 1")
            
            set --local is_ok (string match -q -r '^ok' "$line"; and echo true; or echo false)
            
            # Remove leading "ok" or "not ok" and optional number
            set --local test_line (string replace -r '^(not )?ok( [0-9]+)?' '' "$line" | string trim)
            
            # Check for directives (TODO/SKIP) - case insensitive, after #
            set --local directive ''
            set --local directive_reason ''
            set --local description "$test_line"
            
            # Match directive: \s+#\s*(SKIP|TODO)\S*\s+(.*)
            # Check if there's a # in the line
            if string match -q '*#*' -- "$test_line"
                # Split on ' # ' (space hash space)
                if string match -q '* # *' -- "$test_line"
                    set --local parts (string split -m 1 ' # ' -- "$test_line")
                    if test (count $parts) -eq 2
                        set description "$parts[1]"
                        set --local directive_part "$parts[2]"
                        
                        # Check for TODO or SKIP at start (case insensitive)
                        if string match -q -r -i '^(todo|skip)' -- "$directive_part"
                            # Extract directive type (TODO or SKIP)
                            if string match -q -i 'todo*' -- "$directive_part"
                                set directive 'TODO'
                            else if string match -q -i 'skip*' -- "$directive_part"
                                set directive 'SKIP'
                            end
                            # Extract reason after TODO/SKIP
                            set directive_reason (string replace -r -i '^(todo|skip)\S*\s*' '' -- "$directive_part" | string trim)
                        end
                    end
                end
            end
            
            # Remove leading " - " from description if present
            set description (string replace -r '^\s*-\s*' '' -- "$description" | string trim)
            
            # Unescape \# and \\ in description
            set description (string replace -a '\\#' '#' -- "$description")
            set description (string replace -a '\\\\' '\\' -- "$description")
            
            # Handle different test states
            if test "$directive" = SKIP
                set skip_count (math "$skip_count + 1")
                set --local skip_msg "$description"
                if test -n "$directive_reason"
                    set skip_msg "$skip_msg ($directive_reason)"
                end
                _println "$(_color_dim "$TICK")  $(_color_dim "$skip_msg") $(_color_yellow "# SKIP")" 2
            else if test "$directive" = TODO
                set todo_count (math "$todo_count + 1")
                if test $is_ok = true
                    set pass_count (math "$pass_count + 1")
                    _println "$(_color_green "$TICK")  $(_color_dim "$description") $(_color_yellow "# TODO")" 2
                else
                    # TODO tests that fail are still considered "passing"
                    _println "$(_color_yellow "$CROSS")  $(_color_dim "$description") $(_color_yellow "# TODO")" 2
                end
            else if test $is_ok = true
                set pass_count (math "$pass_count + 1")
                if test -n "$description"
                    _println "$(_color_green "$TICK")  $(_color_dim "$description")" 2
                end
            else
                set fail_count (math "$fail_count + 1")
                set exit_code 1
                set current_test "$description"
                if test -n "$current_test"
                    _println "$(_color_red "$CROSS")  $(_color_red "$current_test")" 2
                else
                    _println "$(_color_red "$CROSS")  $(_color_red "test failed")" 2
                end
            end
            continue
        end
        
        # Parse TAP plan
        if string match -q -r '^1\.\.' "$line"
            set --local plan_match (string replace -r '^1\.\.([0-9]+).*' '$1' "$line")
            if test -n "$plan_match"
                set planned_tests $plan_match
            end
            
            # Check for skip all: 1..0
            if test "$planned_tests" -eq 0
                set --local skip_reason (string replace -r '^1\.\.0\s*#?\s*' '' "$line" | string trim)
                _println "$(_color_yellow "All tests skipped: $skip_reason")"
            end
            continue
        end
        
        # Extra output (stderr, etc) - anything else that's not recognized
        if not string match -q '  *' "$line"; and \
           test -n "$line"
            _println "$(_color_yellow "$line")" 4
        end
    end
    
    # Print summary
    set --local finished_at (date +%s%3N)
    set --local duration (math "$finished_at - $started_at")
    
    if not test $bailed_out = true
        _println
        _println "$(_color_green "passed: $pass_count")  $(_color_red "failed: $fail_count")  $(_color_yellow "skipped: $skip_count")  $(_color_yellow "todo: $todo_count")  $(_color_white "of $test_count tests")  $(_color_dim "("(_format_ms $duration)")")"
        
        # Validate plan
        if test $planned_tests -gt 0 -a $planned_tests -ne $test_count
            _println
            _println "$(_color_red "Planned $planned_tests tests but ran $test_count")"
            set exit_code 1
        end
        
        _println
        
        if test $fail_count -eq 0 -a $planned_tests -eq $test_count
            _println "$(_color_green "All of $test_count tests passed!")"
        else if test $fail_count -gt 0
            _println "$(_color_red "$fail_count of $test_count tests failed.")"
        else
            _println "$(_color_yellow "Test run completed with issues.")"
        end
        _println
    end
    
    return $exit_code
end

# Automatically run tap_reporter if not sourced interactively
# When sourced for testing, functions are available but not executed
if not status is-command-substitution
    and not status is-interactive
    tap_reporter
end
