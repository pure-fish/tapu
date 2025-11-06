#!/usr/bin/env fish
# TAP test line parser and handler

function _parse_test_line
    set --local unindented_line $argv[1]
    set --local directive ''
    set --local directive_reason ''
    set --local description (string replace -r '^(not )?ok( [0-9]+)?' '' "$unindented_line")
    
    # Extract directive (TODO/SKIP) - only if preceded by #
    if string match -q '*#*' -- "$description"
        # Check if there's a directive marker with proper spacing (case-insensitive)
        if string match -q -r -i -- '\s#\s*(todo|skip)' -- "$description"
            set --local parts (string split -m 1 ' # ' -- "$description")
            if test (count $parts) -eq 2
                set --local desc_part (string trim "$parts[1]")
                set --local directive_part "$parts[2]"
                
                if string match -q -r -i -- '^(todo|skip)' -- "$directive_part"
                    if string match -q -i 'todo*' -- "$directive_part"
                        set directive 'TODO'
                    else if string match -q -i 'skip*' -- "$directive_part"
                        set directive 'SKIP'
                    end
                    set directive_reason (string replace -r -i '^(todo|skip)\S*\s*' '' -- "$directive_part" | string trim)
                    set directive_reason (_unescape_tap "$directive_reason")
                    set description "$desc_part"
                end
            else if test (count $parts) -eq 1
                # Handle case where description is empty (starts with #)
                set --local trimmed (string trim "$description")
                if string match -q -r -i -- '^#\s*(todo|skip)' -- "$trimmed"
                    set --local directive_part (string replace -r '^#\s*' '' -- "$trimmed")
                    if string match -q -i 'todo*' -- "$directive_part"
                        set directive 'TODO'
                    else if string match -q -i 'skip*' -- "$directive_part"
                        set directive 'SKIP'
                    end
                    set directive_reason (string replace -r -i '^(todo|skip)\S*\s*' '' -- "$directive_part" | string trim)
                    set directive_reason (_unescape_tap "$directive_reason")
                    set description ''
                end
            end
        end
    end
    
    set description (string replace -r '^\s*-\s*' '' -- "$description" | string trim)
    set description (_unescape_tap "$description")
    
    # Return as pipe-separated string (will be split by caller)
    echo "$directive|$directive_reason|$description"
end

function _output_test_result
    set --export INDENT '  '
    set --export TICK '✔'
    set --export CROSS '✖'

    set --local is_ok $argv[1]
    set --local directive $argv[2]
    set --local directive_reason $argv[3]
    set --local description $argv[4]
    set --local location $argv[5]
    set --local actual $argv[6]
    set --local expected $argv[7]
    
    # Use "undefined" for tests without description (like tap-diff)
    test -z "$description" && set description "undefined"
    
    if test "$directive" = SKIP
        # SKIP tests shown without reason (like tap-diff)
        _println "$(_color_dim "$TICK")  $description" 2
    else if test "$directive" = TODO
        if test $is_ok = true
            # Passing TODO - shown without reason (like tap-diff)
            _println "$(_color_green "$TICK")  $description" 2
        else
            # Failing TODO - shown without reason (like tap-diff)
            _println "$(_color_yellow "$CROSS")  $description" 2
        end
    else if test $is_ok = true
        _println "$(_color_green "$TICK")  $description" 2
    else
        # Failed test - show location inline and actual/expected on next line
        if test -n "$location"
            _println "$(_color_red "$CROSS")  $description at "$(_color_magenta "$location") 2
        else
            _println "$(_color_red "$CROSS")  $description" 2
        end
        
        # Show actual vs expected on the next line with highlighting
        if test -n "$actual" -a -n "$expected"
            # Highlight the actual value (magenta) vs expected (dim)
            set --local colored_actual (_highlight_red "$actual")
            set --local colored_expected (_highlight_green "$expected")
            _println "$colored_actual$colored_expected" 4
        end
    end
end
