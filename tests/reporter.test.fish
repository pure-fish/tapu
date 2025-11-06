#!/usr/bin/env fish
# Main reporter function tests

source (status dirname)/../functions/_tapu_reporter.fish
@echo (set_color blue)(status filename)(set_color normal)


@test "tapu is callable" (functions tapu > /dev/null; echo $status) -eq 0
