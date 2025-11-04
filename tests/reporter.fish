#!/usr/bin/env fish
# Main reporter function tests

source (status dirname)/../functions/tapu.fish
@echo (_color_blue (status filename))


@test "tapu is callable" (functions tapu > /dev/null; echo $status) -eq 0
