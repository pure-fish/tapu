#!/usr/bin/env fish
# TAP (Test Anything Protocol) Reporter for Fish Shell
# A pure fish implementation similar to tap-diff

# Load all helper modules
set --local module_dir (dirname (realpath (status filename)))
source $module_dir/_tapu_colors.fish
source $module_dir/_tapu_formatting.fish
source $module_dir/_tapu_yaml.fish
source $module_dir/_tapu_test.fish
source $module_dir/_tapu_reporter.fish

set --export INDENT '  '
set --export TICK '✔'
set --export CROSS '✖'

# Only run tapu if there's input from a pipe and not interactive
if not status is-interactive
    and test -p /dev/stdin
    tapu
end
