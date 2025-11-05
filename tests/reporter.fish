#!/usr/bin/env fish
# Main reporter function tests

set --local project_root (dirname (dirname (realpath (status filename))))
source $project_root/functions/_tapu_reporter.fish
@echo (_color_blue (status filename))


@test "tapu is callable" (functions tapu > /dev/null; echo $status) -eq 0
