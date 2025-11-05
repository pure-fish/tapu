#!/usr/bin/env fish
# TAP plan validation handler - processes TAP input through tapu reporter

set --local project_root (dirname (dirname (realpath (status filename))))
source $project_root/functions/tapu.fish
