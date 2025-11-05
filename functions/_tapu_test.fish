#!/usr/bin/env fish
# TAP test line parser and handler

function _parse_test_line
    set --local unindented_line $argv[1]
    set --local directive ''
    set --local directive_reason ''
    set --local description (string replace -r '^(not )?ok( [0-9]+)?' '' "$unindented_line" | string trim)
    
    # Extract directive (TODO/SKIP)
    if string match -q '*#*' -- "$description"
        if string match -q '* # *' -- "$description"
            set --local parts (string split -m 1 ' # ' -- "$description")
            if test (count $parts) -eq 2
                set description "$parts[1]"
                set --local directive_part "$parts[2]"
                
                if string match -q -r -i -- '^(todo|skip)' -- "$directive_part"
                    if string match -q -i 'todo*' -- "$directive_part"
                        set directive 'TODO'
                    else if string match -q -i 'skip*' -- "$directive_part"
                        set directive 'SKIP'
                    end
                    set directive_reason (string replace -r -i '^(todo|skip)\S*\s*' '' -- "$directive_part" | string trim)
                    set directive_reason (_unescape_tap "$directive_reason")
                else
                    set description (string replace -r '^\s*-\s*' '' -- "$description" | string trim)
                end
            end
        end
    end
    
    set description (string replace -r '^\s*-\s*' '' -- "$description" | string trim)
    set description (_unescape_tap "$description")
    
    # Return as space-separated string (will be split by caller)
    echo "$directive|$directive_reason|$description"
end

function _output_test_result
    set --local is_ok $argv[1]
    set --local directive $argv[2]
    set --local directive_reason $argv[3]
    set --local description $argv[4]
    
    if test "$directive" = SKIP
        set --local skip_msg "$description"
        test -n "$directive_reason" && set skip_msg "$skip_msg ($directive_reason)"
        _println "$(_color_dim "$TICK")  $(_color_dim "$skip_msg") $(_color_yellow "# SKIP")" 2
    else if test "$directive" = TODO
        if test $is_ok = true
            set --local todo_msg "$description"
            test -n "$directive_reason" && set todo_msg "$todo_msg ($directive_reason)"
            _println "$(_color_green "$TICK")  $(_color_dim "$todo_msg") $(_color_yellow "# TODO")" 2
        else
            set --local todo_msg "$description"
            test -n "$directive_reason" && set todo_msg "$todo_msg ($directive_reason)"
            _println "$(_color_yellow "$CROSS")  $(_color_dim "$todo_msg") $(_color_yellow "# TODO")" 2
        end
    else if test $is_ok = true
        test -n "$description" && _println "$(_color_green "$TICK")  $(_color_dim "$description")" 2
    else
        if test -n "$description"
            _println "$(_color_red "$CROSS")  $(_color_red "$description")" 2
        else
            _println "$(_color_red "$CROSS")  $(_color_red "test failed")" 2
        end
    end
end
