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
    set --local plan_at_end false
    set --local exit_code 0
    set --local in_yaml false
    set --local yaml_lines
    set --local last_comment ''
    set --local seen_test_ids
    set --local tests_after_plan false
    
    while read -l line
        # Skip subtests (4+ space indented lines)
        if string match -q -r -- '^    ' "$line"
            continue
        end
        
        set --local unindented_line (string trim -l "$line")
        
        # Handle Bail out!
        if string match -q -r -i -- '^Bail out!' "$unindented_line"
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
        
        # Handle comments (file headers)
        if string match -q -r -- '^#' "$unindented_line"
            # Skip version lines and summary comments
            if not string match -q -r -- '^# TAP version' "$unindented_line"
                and not string match -q -r -- '^# (pass|fail|skip|todo|ok)' "$unindented_line"
                set --local comment_text (string replace -r '^#\s*' '' "$unindented_line")
                if test -n "$comment_text"
                    # Only print if it's different from last comment (avoid duplicates)
                    if test "$comment_text" != "$last_comment"
                        _println
                        _println "$comment_text" 1
                        set last_comment "$comment_text"
                    end
                end
            end
            continue
        end
        
        # Skip TAP version
        if string match -q -r -- '^TAP version' "$unindented_line"
            continue
        end
        
        # Parse test lines
        if string match -q -r -- '^ok' "$unindented_line"; or string match -q -r -- '^not ok' "$unindented_line"
            # Check if test appears after final plan
            if test $plan_seen = true -a $plan_at_end = true
                _println "$(_color_red "Error: Test found after final plan")"
                set tests_after_plan true
                set exit_code 1
            end
            
            set test_count (math "$test_count + 1")
            
            # Extract test ID if present
            set --local test_id_match (string replace -r '^(not )?ok\s+([0-9]+).*' '$2' "$unindented_line")
            if test "$test_id_match" != "$unindented_line"
                # We got a test ID
                set --local test_id $test_id_match
                
                # Check for duplicate IDs
                if contains -- $test_id $seen_test_ids
                    _println "$(_color_yellow "Warning: Duplicate test ID $test_id")"
                end
                set -a seen_test_ids $test_id
                
                # Check if ID is within plan range (if plan seen before this test)
                if test $plan_seen = true -a $planned_tests -gt 0
                    if test $test_id -lt 1 -o $test_id -gt $planned_tests
                        _println "$(_color_red "Error: Test ID $test_id outside plan range 1..$planned_tests")"
                        set exit_code 1
                    end
                end
            end
            
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
            # Track if plan appears after tests (at end)
            if test $test_count -gt 0
                set plan_at_end true
            end
            
            set --local plan_match (string replace -r '^1\.\.([0-9]+).*' '$1' "$unindented_line")
            test -n "$plan_match" && set planned_tests $plan_match
            
            # Check for skip reason in plan (1..0 # skip reason)
            if test "$planned_tests" -eq 0
                and string match -q '*#*' -- "$unindented_line"
                set --local skip_reason (string replace -r '^1\.\.0\s*#\s*(?:skip\s*)?' '' "$unindented_line" | string trim)
                if test -n "$skip_reason"
                    set skip_reason (_unescape_tap "$skip_reason")
                    _println "$(_color_yellow "Skipped:") $skip_reason"
                end
            end
            continue
        end
    end
    
    # Plan validation
    if not test $plan_seen = true
        _println "$(_color_red "Error: No plan found")"
        set exit_code 1
    else if test $planned_tests -ne $test_count
        _println "$(_color_red "Error: Plan mismatch - planned $planned_tests but ran $test_count tests")"
        set exit_code 1
    end
    
    # Summary - match tap-diff format
    set --local ended_at (date +%s%3N)
    set --local duration (math "$ended_at - $started_at")
    _println
    
    # Build summary line - only show non-zero skip/todo counts
    set --local summary_parts
    set -a summary_parts "$(_color_green "passed: $pass_count")"
    set -a summary_parts "$(_color_red "failed: $fail_count")"
    
    # Only include skipped/todo if they are > 0
    if test $skip_count -gt 0
        set -a summary_parts "$(_color_yellow "skipped: $skip_count")"
    end
    if test $todo_count -gt 0
        set -a summary_parts "$(_color_yellow "todo: $todo_count")"
    end
    
    set -a summary_parts "$(_color_white "of $test_count tests")"
    set -a summary_parts "$(_color_dim "("(_format_ms $duration)")")"
    
    _println (string join "  " $summary_parts)
    _println
    
    if test $fail_count -gt 0
        _println "$(_color_red "$fail_count of $test_count tests failed.")"
    else if test $test_count -gt 0
        _println "$(_color_green "All of $test_count tests passed!")"
    end
    
    _println
    return $exit_code
end
