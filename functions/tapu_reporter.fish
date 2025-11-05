#!/usr/bin/env fish
# TAP reporter main function

function tapu
    set --local started_at (date +%s%3N)
    set --local test_count 0
    set --local pass_count 0
    set --local fail_count 0
    set --local skip_count 0
    set --local todo_count 0
    set --local planned_tests 0
    set --local plan_seen false
    set --local exit_code 0
    set --local in_yaml false
    set --local yaml_lines
    
    while read -l line
        set --local unindented_line (string trim -l "$line")
        
        # Handle Bail out!
        if string match -q -r -- -i -- '^Bail out!' "$unindented_line"
            set --local reason (string replace -r -i '^Bail out!\s*' '' "$unindented_line" | string trim)
            set reason (_unescape_tap "$reason")
            _println; _println "$(_color_red "Bail out!") $reason"; _println
            return 1
        end
        
        # Handle YAML blocks
        if string match -q -- '  ---' "$unindented_line"
            set in_yaml true; set yaml_lines; continue
        else if string match -q -- '  ...' "$unindented_line"
            set in_yaml false
            _parse_yaml_block $yaml_lines
            continue
        end
        
        if test $in_yaml = true
            set -a yaml_lines "$line"; continue
        end
        
        # Skip version and comments
        if string match -q -r -- '^TAP version' "$unindented_line"; or string match -q -- '# *' "$unindented_line"
            continue
        end
        
        # Parse test lines
        if string match -q -r -- '^ok' "$unindented_line"; or string match -q -r -- '^not ok' "$unindented_line"
            set test_count (math "$test_count + 1")
            
            set --local is_ok (string match -q -r -- '^ok' "$unindented_line"; and echo true; or echo false)
            set --local parsed_result (_parse_test_line "$unindented_line")
            set --local directive (echo $parsed_result | cut -d'|' -f1)
            set --local directive_reason (echo $parsed_result | cut -d'|' -f2)
            set --local description (echo $parsed_result | cut -d'|' -f3)
            
            # Update counts
            if test "$directive" = SKIP
                set skip_count (math "$skip_count + 1")
            else if test "$directive" = TODO
                set todo_count (math "$todo_count + 1")
                test $is_ok = true && set pass_count (math "$pass_count + 1")
            else if test $is_ok = true
                set pass_count (math "$pass_count + 1")
            else
                set fail_count (math "$fail_count + 1")
                set exit_code 1
            end
            
            _output_test_result $is_ok "$directive" "$directive_reason" "$description"
            continue
        end
        
        # Parse plan
        if string match -q -r -- '^1\.\.' "$unindented_line"
            set plan_seen true
            set --local plan_match (string replace -r '^1\.\.([0-9]+).*' '$1' "$unindented_line")
            test -n "$plan_match" && set planned_tests $plan_match
            continue
        end
    end
    
    # Summary
    set --local duration (math "(date +%s%3N) - $started_at")
    _println
    _println "$(_color_green "passed: $pass_count")  $(_color_red "failed: $fail_count")  $(_color_yellow "skipped: $skip_count")  $(_color_yellow "todo: $todo_count")  $(_color_white "of $test_count tests")  $(_color_dim "("(_format_ms $duration)")")"
    _println
    
    if test $fail_count -gt 0
        _println "$(_color_red "$fail_count of $test_count tests failed.")"
    else if test $test_count -gt 0
        _println "$(_color_green "All of $test_count tests passed!")"
    end
    
    _println
    return $exit_code
end
