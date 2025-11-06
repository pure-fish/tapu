#!/usr/bin/env fish
# Formatting function tests

source (status dirname)/../functions/_tapu_formatting.fish
@echo (set_color blue)(status filename)(set_color normal)


# _unescape_tap tests
@test "unescape_tap handles escaped hash" (
    test (_unescape_tap 'hello \\# world') = 'hello # world'
    echo $status
) -eq 0

@test "unescape_tap handles escaped backslash" (
    test (_unescape_tap 'hello \\\\ world') = 'hello \ world'
    echo $status
) -eq 0

@test "unescape_tap handles multiple escaped hashes" (
    test (_unescape_tap '\\# test \\# data') = '# test # data'
    echo $status
) -eq 0

@test "unescape_tap handles multiple escaped backslashes" (
    test (_unescape_tap '\\\\\\\\ test') = '\\\\ test'
    echo $status
) -eq 0

@test "unescape_tap handles mixed escaping" (
    test (_unescape_tap 'path\\\\to\\\\file\\#hash') = 'path\\to\\file#hash'
    echo $status
) -eq 0

@test "unescape_tap handles plain text without escapes" (
    test (_unescape_tap 'hello world') = 'hello world'
    echo $status
) -eq 0

@test "unescape_tap handles empty string" (
    test (_unescape_tap '') = ''
    echo $status
) -eq 0

@test "unescape_tap handles backslash before hash (complex)" (
    test (_unescape_tap '\\\\\\#') = '\#'
    echo $status
) -eq 0


# _println tests
@test "println outputs simple text" (
    test (_println "test message") = "test message"
    echo $status
) -eq 0

@test "println outputs empty line for empty input" (
    test (_println "") = ""
    echo $status
) -eq 0

@test "println handles multiline text" (
    set -l result (printf "line1\nline2" | while read -l line; _println "$line"; end)
    string match -q "*line1*" -- "$result"; and string match -q "*line2*" -- "$result"
    echo $status
) -eq 0

@test "println adds no indentation with level 0" (
    test (_println "test" 0) = "test"
    echo $status
) -eq 0

@test "println adds 2 spaces for level 1" (
    test (_println "test" 1) = "  test"
    echo $status
) -eq 0

@test "println adds 4 spaces for level 2" (
    test (_println "test" 2) = "    test"
    echo $status
) -eq 0

@test "println adds 6 spaces for level 3" (
    test (_println "test" 3) = "      test"
    echo $status
) -eq 0

@test "println indents each line in multiline usage" (
    set -l result (printf "line1\nline2" | while read -l line; _println "$line" 1; end)
    string match -q "*  line1*" -- "$result"; and string match -q "*  line2*" -- "$result"
    echo $status
) -eq 0


# _format_ms tests
@test "format_ms handles zero milliseconds" (
    test (_format_ms 0) = "0ms"
    echo $status
) -eq 0

@test "format_ms handles small milliseconds" (
    test (_format_ms 500) = "500ms"
    echo $status
) -eq 0

@test "format_ms handles 999ms" (
    test (_format_ms 999) = "999ms"
    echo $status
) -eq 0

@test "format_ms converts 1000ms to seconds" (
    string match -q "*1}s" (_format_ms 1000)
    echo $status
) -eq 0

@test "format_ms handles exact seconds" (
    string match -q "*5}s" (_format_ms 5000)
    echo $status
) -eq 0

@test "format_ms handles 59 seconds" (
    string match -q "*59}s" (_format_ms 59000)
    echo $status
) -eq 0

@test "format_ms converts to minutes and seconds" (
    set -l result (_format_ms 65000)
    string match -q "*1}m*" -- "$result"; and string match -q "*5}s" -- "$result"
    echo $status
) -eq 0

@test "format_ms handles exact minutes" (
    string match -q "*2}m*0}s" (_format_ms 120000)
    echo $status
) -eq 0

@test "format_ms handles 59 minutes" (
    set -l result (_format_ms 3540000)
    string match -q "*59}m*" -- "$result"
    echo $status
) -eq 0

@test "format_ms converts to hours, minutes, and seconds" (
    set -l result (_format_ms 3665000)
    string match -q "*1}h*" -- "$result"; and string match -q "*1}m*" -- "$result"; and string match -q "*5}s" -- "$result"
    echo $status
) -eq 0

@test "format_ms handles multiple hours" (
    set -l result (_format_ms 7265000)
    string match -q "*2}h*" -- "$result"; and string match -q "*1}m*" -- "$result"; and string match -q "*5}s" -- "$result"
    echo $status
) -eq 0


# _highlight_diff tests
@test "highlight_diff shows identical strings" (
    set -l result (_highlight_diff "hello" "hello")
    string match -q "Actual/Expected: hello" -- "$result"
    echo $status
) -eq 0

@test "highlight_diff shows differences" (
    set -l result (_highlight_diff "hello" "hallo")
    string match -q "*Actual:*" -- "$result"; and string match -q "*Expected:*" -- "$result"
    echo $status
) -eq 0

@test "highlight_diff handles different lengths" (
    set -l result (_highlight_diff "hi" "hello")
    string match -q "*Actual:*" -- "$result"; and string match -q "*Expected:*" -- "$result"
    echo $status
) -eq 0

@test "highlight_diff handles empty actual" (
    set -l result (_highlight_diff "" "test")
    string match -q "*Expected:*" -- "$result"
    echo $status
) -eq 0

@test "highlight_diff handles empty expected" (
    set -l result (_highlight_diff "test" "")
    string match -q "*Actual:*" -- "$result"
    echo $status
) -eq 0

@test "highlight_diff includes ANSI color codes for differences" (
    _highlight_diff "hello" "hallo" | grep -q (printf '\033')
    echo $status
) -eq 0
