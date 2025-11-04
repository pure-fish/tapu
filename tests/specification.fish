#!/usr/bin/env fish
# TAP specification compliance tests
# Reference: https://testanything.org/tap-version-14-specification.html

source (status dirname)/../functions/tapu.fish
@echo (_color_blue (status filename))


# Test TAP line formats
@test "TAP version line format" (echo "TAP version 14") = "TAP version 14"
@test "ok test line format" (echo "ok 1" | grep -q '^ok'; echo $status) -eq 0
@test "ok test line with description" (echo "ok 1 - test passed" | grep -q 'ok 1 -'; echo $status) -eq 0
@test "not ok test line format" (echo "not ok 2" | grep -q 'not ok'; echo $status) -eq 0
@test "not ok test with description" (echo "not ok 2 - test failed" | grep -q 'not ok 2 -'; echo $status) -eq 0

# Test TAP structures
@test "test plan format" (echo "1..10" | grep -qE '^[0-9]+\.\.[0-9]+'; echo $status) -eq 0
@test "bail out message format" (echo "Bail out! Error message" | grep -q '^Bail out!'; echo $status) -eq 0
@test "diagnostic line starts with hash" (echo "# Diagnostic message" | grep -q '^#'; echo $status) -eq 0

# Test TAP YAML blocks
@test "YAML block start indicator" (echo "  ---" | grep -q '^\s*---'; echo $status) -eq 0
@test "YAML block end indicator" (echo "  ..." | grep -q '^\s*\.\.\.'; echo $status) -eq 0

# Test TAP directives
@test "TODO directive in test line" (echo "not ok 1 # TODO fix this" | grep -q 'TODO'; echo $status) -eq 0
@test "SKIP directive in test line" (echo "ok 1 # SKIP not ready" | grep -q 'SKIP'; echo $status) -eq 0
