#!/usr/bin/env fish
# TAP specification plan validation tests
# Reference: https://testanything.org/tap-version-14-specification.html#plan

source (status dirname)/../functions/tapu.fish
@echo (_color_blue (status filename))


# Test plan at beginning
@test "plan at beginning is valid" (
    printf "TAP version 14\n1..3\nok 1\nok 2\nok 3\n" | tapu >/dev/null 2>&1
    echo $status
) -eq 0

# Test plan at end
@test "plan at end is valid" (
    printf "TAP version 14\nok 1\nok 2\nok 3\n1..3\n" | tapu >/dev/null 2>&1
    echo $status
) -eq 0

# Test plan count mismatch
@test "plan count mismatch fails" (
    printf "TAP version 14\n1..5\nok 1\nok 2\nok 3\n" | tapu >/dev/null 2>&1
    echo $status
) -eq 1

# Test more tests than planned
@test "more tests than planned fails" (
    printf "TAP version 14\n1..2\nok 1\nok 2\nok 3\n" | tapu >/dev/null 2>&1
    echo $status
) -eq 1

# Test test ID outside plan range
@test "test ID outside plan range should fail" (
    printf "TAP version 14\n1..3\nok 2\nok 4\nok 1\n" | tapu >/dev/null 2>&1
    echo $status
) -eq 1

# Test duplicate test IDs
@test "duplicate test IDs should warn" (
    printf "TAP version 14\n1..3\nok 1\nok 2\nok 1\n" | tapu 2>&1 | grep -qi "duplicate\|repeated"
    echo $status
) -eq 0

# Test skip-all plan
@test "1..0 plan means skip all" (
    printf "TAP version 14\n1..0 # skip all tests\n" | tapu 2>&1 | grep -qi "skip"
    echo $status
) -eq 0

# Test tests after final plan (invalid)
@test "tests after final plan should fail" (
    printf "TAP version 14\nok 1\nok 2\n1..2\nok 3\n" | tapu >/dev/null 2>&1
    echo $status
) -eq 1

# Test plan without version
@test "missing version with plan" (
    printf "1..3\nok 1\nok 2\nok 3\n" | tapu >/dev/null 2>&1
    echo $status
) -eq 0

# Test missing plan
@test "missing plan should fail" (
    printf "TAP version 14\nok 1\nok 2\n" | tapu >/dev/null 2>&1
    echo $status
) -eq 1
